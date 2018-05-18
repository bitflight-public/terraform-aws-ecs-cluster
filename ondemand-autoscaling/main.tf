module "label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.5"

  namespace   = "${var.namespace}"
  stage       = "${var.stage}"
  name        = "${var.name}"
  delimiter   = "${var.delimiter}"
  attributes  = "${var.attributes}"
  tags        = "${var.tags}"
  additional_tag_map = {
    propagate_at_launch = "true"
  }
}
#
# AutoScaling resources
#
data "template_file" "default_base_cloud_config" {
  template = "${file("${path.module}/../cloud-config/base-container-instance.yml.tpl")}"

  vars {
    ecs_cluster_name = "${var.cluster_name}"
  }
}

data "template_cloudinit_config" "default_cloud_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.default_base_cloud_config.rendered}"
  }

  part {
    content_type = "${var.cloud_config_content_type}"
    content      = "${var.cloud_config_content}"
  }
}

data "aws_ami" "ecs_ami" {
  count       = "${var.lookup_latest_ami ? 1 : 0}"
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["${var.ami_owners}"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "user_ami" {
  count  = "${var.lookup_latest_ami ? 0 : 1}"
  owners = ["${var.ami_owners}"]

  filter {
    name   = "image-id"
    values = ["${var.ami_id}"]
  }
}

resource "aws_launch_configuration" "default" {
  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "${var.root_block_device_type}"
    volume_size = "${var.root_block_device_size}"
  }

  name_prefix          = "${module.label.id}-"
  iam_instance_profile = "${var.instance_profile_name}"

  # Using join() is a workaround for depending on conditional resources.
  # https://github.com/hashicorp/terraform/issues/2831#issuecomment-298751019
  image_id = "${var.lookup_latest_ami ? join("", data.aws_ami.ecs_ami.*.image_id) : join("", data.aws_ami.user_ami.*.image_id)}"

  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${var.security_group_id}"]
  user_data       = "${data.template_cloudinit_config.default_cloud_config.rendered}"
}

resource "aws_autoscaling_group" "default" {
  lifecycle {
    create_before_destroy = true
  }

  name                      = "${module.label.id}"
  launch_configuration      = "${aws_launch_configuration.default.name}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "EC2"
  desired_capacity          = "${var.desired_capacity}"
  termination_policies      = ["OldestLaunchConfiguration", "Default"]
  min_size                  = "${var.min_size}"
  max_size                  = "${var.max_size}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  vpc_zone_identifier       = ["${var.private_subnet_ids}"]

  tags = ["${module.label.tags_as_list_of_maps}"]
}
