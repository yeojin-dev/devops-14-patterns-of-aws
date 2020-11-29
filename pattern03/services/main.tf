resource "aws_lb" "intra" {
  name = "intra-alb"
  internal = true
  load_balancer_type = "application"
  security_groups = []
  subnets = [var.subnet_a_id, var.subnet_b_id]
}

resource "aws_security_group" "intra_alb" {
  name = "intra-alb-sg"
  description = "sg for intra alb"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "intra_alb_ingress" {
  security_group_id = aws_security_group.intra_alb.id
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "intra_alb_egress" {
  security_group_id = aws_security_group.intra_alb.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_security_group" "intra_instance" {
  name = "intra-instance-sg"
  description = "sg for intra instance"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "intra_instance_ingress" {
  security_group_id = aws_security_group.intra_instance.id
  from_port = 80
  protocol = "tcp"
  to_port = 80
  source_security_group_id = aws_security_group.intra_instance.id
  type = "ingress"
}

resource "aws_security_group_rule" "intra_instance_egress" {
  security_group_id = aws_security_group.intra_instance.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}
