/* redis(multi-az disabled)
resource "aws_elasticache_cluster" "intra" {
  cluster_id = "intra"
  engine = "redis"
  node_type = "cache.t2.micro"  // https://aws.amazon.com/ko/elasticache/pricing/
  num_cache_nodes = 1
  parameter_group_name = "default.redis5.0"
  engine_version = "5.0.6"
  port = 6379
  subnet_group_name = aws_elasticache_subnet_group.intra.name
}
*/

// redis(multi-az enabled)
resource "aws_elasticache_replication_group" "intra" {
  replication_group_id = "intra-redis-cluster"
  replication_group_description = ""
  node_type = "cache.t2.micro"
  port = 6379
  parameter_group_name = "default.redis6.x.cluster.on"
  automatic_failover_enabled = true
  subnet_group_name = aws_elasticache_subnet_group.intra.name

  cluster_mode {
    num_node_groups = 1
    replicas_per_node_group = 2
  }
}

resource "aws_elasticache_subnet_group" "intra" {
  name = "intra"
  subnet_ids = [var.subnet_a_id, var.subnet_b_id]
}

// AWS Aurora
resource "aws_rds_cluster" "intra" {
  cluster_identifier = "intra-aurora"
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.07.2"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2b"]
  database_name = "intra"

  master_username = "foo"
  master_password = "foobarbaz"

  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  db_subnet_group_name = aws_db_subnet_group.intra.name
  vpc_security_group_ids = [aws_security_group.intra_rds.id]

  skip_final_snapshot = true
}

// AWS Aurora replica
resource "aws_rds_cluster_instance" "intra_replica" {
  cluster_identifier = aws_rds_cluster.intra.id
  // 가능한 인스턴스 클래스 확인
  // https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
  instance_class = "db.t2.small"
  identifier = "intra-aurora-replica"
  engine = aws_rds_cluster.intra.engine
  engine_version = aws_rds_cluster.intra.engine_version

}

resource "aws_db_subnet_group" "intra" {
  name = "intra-rds-subnet-group"
  subnet_ids = [var.subnet_a_id, var.subnet_b_id]
}

resource "aws_security_group" "intra_rds" {
  name = "intra-rds-sg"
  description = "sg for intra rds"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "intra_rds_ingress" {
  from_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.intra_rds.id
  to_port = 3306
  cidr_blocks = ["192.168.0.0/16"]
  description = "VPC cidr"
  type = "ingress"
}

resource "aws_security_group_rule" "intra_rds_egress" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.intra_rds.id
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}
