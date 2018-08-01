resource "aws_efs_file_system" "ecs" {
  creation_token = "${var.stage}-ecs"
  tags {
    Name = "${var.stage}-ecs"
  }
}

resource "aws_efs_mount_target" "ecs" {
  count = "${length(module.vpc.private_subnets)}"
  file_system_id = "${aws_efs_file_system.ecs.id}"
  subnet_id = "${module.vpc.private_subnets[count.index]}"
}