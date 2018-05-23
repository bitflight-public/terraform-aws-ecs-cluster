module "label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.5"

  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = ["${var.attributes}"]
  tags       = "${var.tags}"

  additional_tag_map = {
    propagate_at_launch = "true"
  }
}

module "ondemand" {
  source = "./ondemand-autoscaling"

  namespace   = "${var.namespace}"
  stage       = "${var.stage}"
  name        = "${var.name}"
  delimiter   = "${var.delimiter}"
  attributes  = ["ondemand", "${var.attributes}"]
  tags        = "${var.tags}"
  ec2_cluster = "${var.ec2_cluster}"

  additional_tag_map = {
    propagate_at_launch = "true"
  }

  vpc_id                    = "${var.vpc_id}"
  cloud_config_content_type = "${var.cloud_config_content_type}"
  cloud_config_content      = "${var.cloud_config_content}"
  lookup_latest_ami         = "${var.lookup_latest_ami}"
  ami_owners                = "${var.ami_owners}"
  root_block_device_type    = "${var.root_block_device_type}"
  root_block_device_size    = "${var.root_block_device_size}"
  instance_type             = "${var.instance_type}"
  key_name                  = "${var.key_name}"
  health_check_grace_period = "${var.health_check_grace_period}"
  desired_capacity          = "${var.desired_capacity}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  enabled_metrics           = "${var.enabled_metrics}"
  private_subnet_ids        = "${var.private_subnet_ids}"
  security_group_id         = "${aws_security_group.default.id}"
  cluster_name              = "${aws_ecs_cluster.default.name}"
  instance_profile_name     = "${aws_iam_instance_profile.default.name}"
}

#
# Security group resources
#
resource "aws_security_group" "default" {
  vpc_id      = "${var.vpc_id}"
  name_prefix = "${module.label.id}"

  tags = "${module.label.tags}"
}

resource "aws_security_group_rule" "allow_access_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.default.id}"
}

#
# ECS resources
#
resource "aws_ecs_cluster" "default" {
  name = "${module.label.id}"
}
