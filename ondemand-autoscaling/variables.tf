variable "namespace" {
  description = "Namespace, which could be your organization name, e.g. 'cp' or 'cloudposse'"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `policy` or `role`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "additional_tag_map" {
  type        = "map"
  default     = {}
  description = "Additional tags for appending to each tag map."
}

variable "ec2_cluster" {
  description = "create a cluster using ec2 asg"
  default     = "true"
}

variable "cluster_name" {}

variable "instance_profile_name" {}

variable "security_group_id" {
  default = ""
}

variable "vpc_id" {}

variable "ami_id" {
  default = "ami-6944c513"
}

variable "ami_owners" {
  default = ["self", "amazon", "aws-marketplace"]
}

variable "lookup_latest_ami" {
  default = false
}

variable "root_block_device_type" {
  default = "gp2"
}

variable "root_block_device_size" {
  default = "8"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {}

variable "cloud_config_content" {}

variable "cloud_config_content_type" {
  default = "text/cloud-config"
}

variable "health_check_grace_period" {
  default = "600"
}

variable "desired_capacity" {
  default = "1"
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "1"
}

variable "enabled_metrics" {
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "scale_up_cooldown_seconds" {
  default = "300"
}

variable "scale_down_cooldown_seconds" {
  default = "300"
}

variable "high_cpu_evaluation_periods" {
  default = "2"
}

variable "high_cpu_period_seconds" {
  default = "300"
}

variable "high_cpu_threshold_percent" {
  default = "90"
}

variable "low_cpu_evaluation_periods" {
  default = "2"
}

variable "low_cpu_period_seconds" {
  default = "300"
}

variable "low_cpu_threshold_percent" {
  default = "10"
}

variable "high_memory_evaluation_periods" {
  default = "2"
}

variable "high_memory_period_seconds" {
  default = "300"
}

variable "high_memory_threshold_percent" {
  default = "90"
}

variable "low_memory_evaluation_periods" {
  default = "2"
}

variable "low_memory_period_seconds" {
  default = "300"
}

variable "low_memory_threshold_percent" {
  default = "10"
}
