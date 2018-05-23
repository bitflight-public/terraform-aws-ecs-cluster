module "label" {
  source = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"

  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
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

#######################
# Launch template     #
#######################
resource "aws_launch_template" "launch" {
  count = "${var.ec2_cluster == "true" ? 1 : 0}"

  # terraform-null-label example used here: Set template name prefix

  lifecycle {
    create_before_destroy = true
  }
  name_prefix                          = "${module.label.id}-"
  image_id                             = "${var.lookup_latest_ami ? join("", data.aws_ami.ecs_ami.*.image_id) : join("", data.aws_ami.user_ami.*.image_id)}"
  instance_type                        = "${var.instance_type}"
  key_name                             = "${var.key_name}"
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    name = "${var.instance_profile_name}"
  }
  vpc_security_group_ids = ["${var.security_group_id}"]
  monitoring {
    enabled = true
  }
  # terraform-null-label example used here: Set tags on volumes
  tag_specifications {
    resource_type = "volume"
    tags          = "${module.label.tags}"
  }
  tag_specifications {
    resource_type = "instance"
    tags          = "${module.label.tags}"
  }

  # block_device_mappings {
  #   device_name = "/dev/xvda"


  #   ebs {
  #     encrypted = false
  #     volume_type = "${var.root_block_device_type}"
  #     volume_size = "${var.root_block_device_size}"
  #   }
  # }

  user_data = "${base64encode(data.template_cloudinit_config.default_cloud_config.rendered)}"
}

resource "aws_autoscaling_group" "default" {
  count = "${var.ec2_cluster == "true" ? 1 : 0}"

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${module.label.id}"

  launch_template = {
    id      = "${aws_launch_template.launch.0.id}"
    version = "$$Latest"
  }

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "EC2"
  desired_capacity          = "${var.desired_capacity}"
  termination_policies      = ["OldestLaunchConfiguration", "Default"]
  min_size                  = "${var.min_size}"
  max_size                  = "${var.max_size}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  vpc_zone_identifier       = ["${var.private_subnet_ids}"]

  depends_on = ["aws_launch_template.launch"]
}
