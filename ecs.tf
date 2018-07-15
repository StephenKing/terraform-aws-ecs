variable stage {
  default = "prod"
}

variable "ssh_key_name" {
  default = "st"
}

variable "cluster_size" {
  default = 2
}

resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
}

data "aws_region" "current" {}

resource "aws_subnet" "private" {
  count      = 3
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, "${count.index}")}"

  tags {
    Name = "private ${var.stage}"
  }
}

resource "aws_ecs_cluster" "default" {
  name = "${var.stage}"
}

resource "aws_security_group" "ecs_instance" {
  name = "ecs-instance-${var.stage}"
  vpc_id = "${aws_vpc.main.id}"

  # TODO secure
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_spot_fleet_request" "ecs" {
  iam_fleet_role = "${aws_iam_role.ecs_spotfleet.arn}"

  launch_specification {
    # TODO use search
    ami                  = "ami-5253c32d"
    key_name             = "${var.ssh_key_name}"
    instance_type        = "m4.large"
    # TODO documentation says iam_instance_profile_arn ??
    iam_instance_profile_arn = "${aws_iam_instance_profile.ecs_instance.arn}"

    # TODO can be only one subnet???
    subnet_id              = "${aws_subnet.private.0.id}"
    vpc_security_group_ids = ["${aws_security_group.ecs_instance.id}"]
    user_data              = "${data.template_cloudinit_config.ecs_init.rendered}"

    tags {
      # TODO redundant stage
      Name = "ecs-${aws_ecs_cluster.default.name}-${var.stage}"
    }
  }

  spot_price                  = "10"
  target_capacity             = "${var.cluster_size}"
  replace_unhealthy_instances = true
  wait_for_fulfillment        = true
}

data "aws_iam_policy" "AmazonEC2ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "AmazonEC2SpotFleetRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole"
}

data "aws_iam_policy" "AmazonEC2SpotFleetTaggingRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data template_file "ecs_init" {
  template = "${file("user-data-ecs-instance.sh.tpl")}"

  # template = "${file("${path.module}/user-data-ecs-instance.sh.tpl")}"

  vars {
    aws_region                = "${data.aws_region.current.name}"
    ecs_cluster               = "${aws_ecs_cluster.default.name}"
    efs_file_system           = "TODO" // TODO!!
    cloudwatch_log_group_name = "ECS-${aws_ecs_cluster.default.name}"
  }
}

data "template_cloudinit_config" "ecs_init" {
  gzip          = true
  base64_encode = true

  "part" {
    filename     = "init.cfg"
    content_type = "text/part-handler"
    content      = "${data.template_file.ecs_init.rendered}"
  }
}
data "aws_iam_policy_document" "assume_spotfleet" {

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_spotfleet" {
  name = "${data.aws_region.current.name}-ecs-spotfleet-${var.stage}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_spotfleet.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_AmazonEC2SpotFleetRole" {
  policy_arn = "${data.aws_iam_policy.AmazonEC2SpotFleetRole.arn}"
  role       = "${aws_iam_role.ecs_spotfleet.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_AmazonEC2SpotFleetTaggingRole" {
  policy_arn = "${data.aws_iam_policy.AmazonEC2SpotFleetTaggingRole.arn}"
  role       = "${aws_iam_role.ecs_spotfleet.id}"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  # better user name_prefix?
  name = "${data.aws_region.current.name}-ecs-instance-${var.stage}"
  path = "/"
  role = "${aws_iam_role.ecs_spotfleet.id}"
}

resource "aws_iam_role" "ecs_instance" {
  name = "${data.aws_region.current.name}-ecs-instance-${var.stage}"

  # TODO move this into a template to only replace the service!
  # or what about https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html ?
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  path = "/"
}

#  Allow the spot instance to set itself to DRAINING on termination notification
resource "aws_iam_policy" "ecs_instance_state" {
  name   = "${data.aws_region.current.name}-ecs-instance-state-${var.stage}"
  policy = "${data.aws_iam_policy_document.ecs_instance_state.json}"
}

data "aws_iam_policy_document" "ecs_instance_state" {
  statement {
    actions   = [
      "ecs:UpdateContainerInstancesState"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "ecs_instance_cloudwatch_logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    # TODO make this more restricitve
    resources = ["arn:aws:logs:*:*:*"]
  }
}

#  Allow the spot instance to send CloudWatch Logs
resource "aws_iam_policy" "ecs_instance_cloudwatch_logs" {
  name   = "${data.aws_region.current.name}-ecs-instance-cloudwatch-logs-${var.stage}"
  policy = "${data.aws_iam_policy_document.ecs_instance_cloudwatch_logs.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_AmazonEC2ReadOnlyAccess" {
  policy_arn = "${data.aws_iam_policy.AmazonEC2ReadOnlyAccess.arn}"
  role       = "${aws_iam_role.ecs_instance.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_AmazonEC2ContainerServiceforEC2Role" {
  policy_arn = "${data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn}"
  role       = "${aws_iam_role.ecs_instance.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_state" {
  policy_arn = "${aws_iam_policy.ecs_instance_state.arn}"
  role       = "${aws_iam_role.ecs_instance.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_cloudwatch_logs" {
  policy_arn = "${aws_iam_policy.ecs_instance_cloudwatch_logs.arn}"
  role       = "${aws_iam_role.ecs_instance.id}"
}
