output "redis_endpoint" {
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
  description = "The connection endpoint for the Redis Replication Group"
}
