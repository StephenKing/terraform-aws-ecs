variable stage {
  default = "prod"
}

variable "ssh_key_name" {
  default = "steffen.gebert"
}

variable "cluster_size" {
  default = 1
}

//resource "aws_vpc" "main" {
//  cidr_block = "10.10.0.0/16"
//}

data "aws_region" "current" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tf-test"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true
  enable_dns_hostnames = true # also needed for EFS

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

//resource "aws_subnet" "private" {
//  count      = 3
//  vpc_id     = "${module.vpc.vpc_id}"
//  cidr_block = "${cidrsubnet(module.vpc.cidr_block, 8, "${count.index}")}"
//
//  tags {
//    Name = "private ${var.stage}"
//  }
//}

resource "aws_ecs_cluster" "default" {
  name = "${var.stage}"
}

resource "aws_security_group" "ecs_instance" {
  name = "ecs-instance-${var.stage}"
  vpc_id = "${module.vpc.vpc_id}"

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

data "aws_ami" "ecs" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}
resource "aws_spot_fleet_request" "ecs" {
  iam_fleet_role = "${aws_iam_role.ecs_spotfleet_instance.arn}"

  launch_specification {
    ami                  = "${data.aws_ami.ecs.id}"
    key_name             = "${var.ssh_key_name}"
    instance_type        = "m4.large"
    # TODO documentation says iam_instance_profile_arn ??
    iam_instance_profile_arn = "${aws_iam_instance_profile.ecs_instance.arn}"

    # TODO can be only one subnet???
    subnet_id              = "${module.vpc.private_subnets[0]}"
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
  terminate_instances_with_expiration = true
  # reduce the downtime a bit..
  lifecycle {
    create_before_destroy = true
  }
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
    efs_file_system           = "${aws_efs_file_system.ecs.dns_name}" // TODO!!
    cloudwatch_log_group_name = "ECS-${aws_ecs_cluster.default.name}"
  }
}

data "template_cloudinit_config" "ecs_init" {
  gzip          = false
  base64_encode = true

  "part" {
    filename     = "init.cfg"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.ecs_init.rendered}"
  }
}
data "aws_iam_policy_document" "assume_spotfleet" {

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["spotfleet.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_spotfleet_instance" {
  name = "${data.aws_region.current.name}-ecs-spotfleet123-${var.stage}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_spotfleet.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_AmazonEC2SpotFleetRole" {
  policy_arn = "${data.aws_iam_policy.AmazonEC2SpotFleetRole.arn}"
  role       = "${aws_iam_role.ecs_spotfleet_instance.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_AmazonEC2SpotFleetTaggingRole" {
  policy_arn = "${data.aws_iam_policy.AmazonEC2SpotFleetTaggingRole.arn}"
  role       = "${aws_iam_role.ecs_spotfleet_instance.id}"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  # better user name_prefix?
  name = "${data.aws_region.current.name}-ecs-instance-${var.stage}"
  path = "/"
  role = "${aws_iam_role.ecs_spotfleet_instance.id}"
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
  role       = "${aws_iam_role.ecs_spotfleet_instance.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_AmazonEC2ContainerServiceforEC2Role" {
  policy_arn = "${data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn}"
  role       = "${aws_iam_role.ecs_spotfleet_instance.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_state" {
  policy_arn = "${aws_iam_policy.ecs_instance_state.arn}"
  role       = "${aws_iam_role.ecs_spotfleet_instance.id}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_cloudwatch_logs" {
  policy_arn = "${aws_iam_policy.ecs_instance_cloudwatch_logs.arn}"
  role       = "${aws_iam_role.ecs_spotfleet_instance.id}"
}
