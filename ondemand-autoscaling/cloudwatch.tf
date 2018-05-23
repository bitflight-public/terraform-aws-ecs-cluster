#
# CloudWatch resources
#
resource "aws_autoscaling_policy" "default_scale_up" {
  count                  = "${var.ec2_cluster == "true" ? 1 : 0}"
  name                   = "${module.label.id}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.scale_up_cooldown_seconds}"
  autoscaling_group_name = "${aws_autoscaling_group.default.0.name}"
}

resource "aws_autoscaling_policy" "default_scale_down" {
  count                  = "${var.ec2_cluster == "true" ? 1 : 0}"
  name                   = "${module.label.id}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.scale_down_cooldown_seconds}"
  autoscaling_group_name = "${aws_autoscaling_group.default.0.name}"
}

resource "aws_cloudwatch_metric_alarm" "default_high_cpu" {
  count               = "${var.ec2_cluster == "true" ? 1 : 0}"
  alarm_name          = "${module.label.id}-cpu-reservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_cpu_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.high_cpu_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.high_cpu_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster_name}"
  }

  alarm_description = "Scale up if CPUReservation is above N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.default_scale_up.0.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "default_low_cpu" {
  count               = "${var.ec2_cluster == "true" ? 1 : 0}"
  alarm_name          = "${module.label.id}-cpu-reservation-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.low_cpu_evaluation_periods}"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "${var.low_cpu_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.low_cpu_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster_name}"
  }

  alarm_description = "Scale down if the CPUReservation is below N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.default_scale_down.0.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.default_high_cpu"]
}

resource "aws_cloudwatch_metric_alarm" "default_high_memory" {
  count               = "${var.ec2_cluster == "true" ? 1 : 0}"
  alarm_name          = "${module.label.id}-memory-reservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_memory_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.high_memory_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.high_memory_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster_name}"
  }

  alarm_description = "Scale up if the MemoryReservation is above N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.default_scale_up.0.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.default_low_cpu"]
}

resource "aws_cloudwatch_metric_alarm" "default_low_memory" {
  count               = "${var.ec2_cluster == "true" ? 1 : 0}"
  alarm_name          = "${module.label.id}-memory-reservation-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.low_memory_evaluation_periods}"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "${var.low_memory_period_seconds}"
  statistic           = "Maximum"
  threshold           = "${var.low_memory_threshold_percent}"

  dimensions {
    ClusterName = "${var.cluster_name}"
  }

  alarm_description = "Scale down if the MemoryReservation is below N% for N duration"
  alarm_actions     = ["${aws_autoscaling_policy.default_scale_down.0.arn}"]

  depends_on = ["aws_cloudwatch_metric_alarm.default_high_memory"]
}
