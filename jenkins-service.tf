data "template_file" "jenkins_task_definition" {
  template = "${file("jenkins-task-definition.json")}"
  vars {
    jenkins_container_tag = "latest"
  }
}

resource "aws_ecs_task_definition" "jenkins" {
  container_definitions = "${data.template_file.jenkins_task_definition.rendered}"
  ## check if it makes sense to define this per stage..?
  family = "jenkins-master-${var.stage}"
  network_mode = "awsvpc"
  volume {
    name = "efs-jenkins-${var.stage}"
    host_path = "/mnt/ECSFS/jenkins-${var.stage}"
  }
//  task_role_arn = ""
}

resource "aws_ecs_service" "jenkins" {
  name = "jenkins-${var.stage}"
  task_definition = "${aws_ecs_task_definition.jenkins.family}:${aws_ecs_task_definition.jenkins.revision}"
  cluster = "${aws_ecs_cluster.default.arn}"
  desired_count = 1
  //  iam_role = "${aws_iam_role.jenkins_assume_role.arn}"

  # plugin extraction during startup might take a long time
  health_check_grace_period_seconds = "600"

  load_balancer {
    container_name = "jenkins"
    container_port = 8080
    target_group_arn = "${aws_alb_target_group.jenkins.id}"
  }
  network_configuration {
    subnets = ["${module.vpc.private_subnets}"]
    security_groups = ["${aws_security_group.jenkins.id}"]
  }
  # depends_on = ["${aws_iam_role_policy}"] # TODO see TF docs
}

resource "aws_security_group" "jenkins" {
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_alb_target_group" "jenkins" {
  depends_on = ["aws_alb.internal"]
  name = "${var.stage}-jenkins"
  port = 80
  protocol = "HTTP"
  vpc_id = "${module.vpc.vpc_id}"
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener" "jenkins" {
  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins.arn}"
    type = "forward"
  }

  load_balancer_arn = "${aws_alb.internal.arn}"
  port = 80
}
#### FIXME
//data "aws_iam_policy_document" "jenkins" {
//  statement {
//    actions = ["sts:AssumeRole"]
//    principals {
//      type = "Service"
//      identifiers = ["spotfleet.amazonaws.com"] #todo
//    }
//  }
//}
//
//resource "aws_iam_role" "jenkins_assume_role" {
//  name = "${data.aws_region.current.name}-jenkins-${var.stage}"
//  assume_role_policy = "${aws_iam_role.jenkins_assume_role.arn}"
//}
//
//resource "aws_iam_role_policy" "" {
//  policy = "${data.}"
//  role = "${aws_iam_role.jenkins_assume_role.arn}"
//}