output "rds_address" {
  value = aws_db_instance.rds_db_instance.address
}

output "rds_username" {
  value = aws_db_instance.rds_db_instance.username
}

output "rds_password" {
  value = aws_db_instance.rds_db_instance.password
}

output "redis_address" {
  value = aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address
}