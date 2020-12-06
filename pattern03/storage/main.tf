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
