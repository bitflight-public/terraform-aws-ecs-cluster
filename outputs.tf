output "id" {
  value = "${aws_ecs_cluster.default.id}"
}

output "name" {
  value = "${aws_ecs_cluster.default.name}"
}

output "container_instance_security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "container_instance_ecs_for_ec2_service_role_name" {
  value = "${aws_iam_role.default_ec2.name}"
}

output "ecs_service_role_name" {
  value = "${aws_iam_role.ecs_service_role.name}"
}

output "ecs_autoscale_role_name" {
  value = "${aws_iam_role.ecs_autoscale_role.name}"
}

output "ecs_service_role_arn" {
  value = "${aws_iam_role.ecs_service_role.arn}"
}

output "ecs_autoscale_role_arn" {
  value = "${aws_iam_role.ecs_autoscale_role.arn}"
}

output "container_instance_ecs_for_ec2_service_role_arn" {
  value = "${aws_iam_role.default_ec2.arn}"
}
