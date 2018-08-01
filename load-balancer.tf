resource "aws_alb" "internal" {
  name               = "${var.stage}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_internal.id}"]
  subnets            = ["${module.vpc.private_subnets}"]

  enable_deletion_protection = false

  tags {
    Stage = "${var.stage}"
  }
}

//resource "aws_lb_listener" "internal" {
//  load_balancer_arn = "${aws_alb.internal.arn}"
//  port              = 80
//  protocol          = "HTTP"
//
//  default_action {
//    target_group_arn = "${aws_alb_target_group.default.arn}"
//    type             = "forward"
//  }
//}

resource "aws_alb_target_group" "default" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_security_group" "alb_internal" {
  name = "Internal ALB ${var.stage}"
  description = "Group associated with internal ALB in stage ${var.stage} to allow access for it to other instances"
  vpc_id = "${module.vpc.vpc_id}"
}
