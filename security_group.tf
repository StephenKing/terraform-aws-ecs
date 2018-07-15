//data "aws_vpc" "vpc" {}
//
//variable "ingress_cidr" {
//  type = "list"
//  default = ["0.0.0.0/0"]
//}
//
//resource "aws_security_group" "allow_all" {
//  name        = "tf_test_allow_all"
//  description = "Terraform Allow all inbound traffic"
//  vpc_id      = "${data.aws_vpc.vpc.id}"
//
//  ingress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = "${var.ingress_cidr}"
//  }
//
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}
