#
# Container Instance IAM resources
#
data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "default_ec2" {
  name               = "${module.label.id}-container-instance-profile"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_role_policy_attachment" "ec2_service_role" {
  role       = "${aws_iam_role.default_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "default" {
  name = "${aws_iam_role.default_ec2.name}"
  role = "${aws_iam_role.default_ec2.name}"
}

#
# ECS Service IAM permissions
#
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid = "1"

    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "ec2:DescribeTags",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "cloudwatch" {
  name   = "${module.label.id}-cloudwatch-stats"
  path   = "/"
  policy = "${data.aws_iam_policy_document.cloudwatch.json}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch.arn}"
}

data "aws_iam_policy_document" "ecs" {
  statement {
    sid = "1"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs" {
  name   = "${module.label.id}-ecs-policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ecs.json}"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "${aws_iam_policy.ecs.arn}"
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "${module.label.id}-service-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_role" {
  role       = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_autoscale_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_autoscale_role" {
  name               = "${module.label.id}-autoscale-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_autoscale_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_autoscaling_role" {
  role       = "${aws_iam_role.ecs_autoscale_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}