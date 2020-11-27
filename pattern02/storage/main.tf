resource "aws_db_instance" "enterprise" {
  allocated_storage = 20
  storage_type = "gp2"  // general purpose SSD
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "enterprise"  // 기본 데이터베이스 스키마
  identifier = "enterprise-db"

  // TODO: 변수 처리
  username = "foo"
  password = "foobarbaz"

  parameter_group_name = "default.mysql5.7"
  multi_az = true
  db_subnet_group_name = aws_db_subnet_group.enterprise.name
  vpc_security_group_ids = [aws_security_group.enterprise_rds.id]

  skip_final_snapshot = true  // 바로 destroy 가능하도록
}

resource "aws_db_subnet_group" "enterprise" {
  name = "enterprise-rds-subnet-group"
  subnet_ids = [var.subnet_a_id, var.subnet_b_id]
}

resource "aws_security_group" "enterprise_rds" {
  name = "enterprise-rds-sg"
  description = "sg for enterprise rds"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "enterprise_instance_ingress" {
  security_group_id = aws_security_group.enterprise_rds.id
  from_port = 3306
  protocol = "tcp"
  to_port = 3306
  cidr_blocks = ["192.168.0.0/16"]
  description = "VPC cidr"
  type = "ingress"
}

resource "aws_security_group_rule" "enterprise_instance_egress" {
  security_group_id = aws_security_group.enterprise_rds.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}
