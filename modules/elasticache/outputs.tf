output "redis_endpoint" {
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
  description = "The connection endpoint for the Redis Replication Group"
}

output "redis_port" {
  value       = aws_elasticache_replication_group.main.port
  description = "The Redis port"
}

output "redis_security_group_id" {
  value       = aws_security_group.redis.id
  description = "The Redis security group ID"
}
