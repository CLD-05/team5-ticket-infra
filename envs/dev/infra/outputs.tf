output "rds_endpoint" {
  value       = module.database.db_endpoint
  description = "Dev RDS endpoint"
}

output "rds_proxy_endpoint" {
  value       = module.database.db_proxy_endpoint
  description = "Dev RDS Proxy connection endpoint"
}

output "redis_endpoint" {
  value       = module.elasticache.redis_endpoint
  description = "Dev Redis endpoint"
}

output "sqs_booking_queue_url" {
  value       = module.sqs.queue_url
  description = "Dev booking queue URL"
}

output "sqs_booking_queue_arn" {
  value       = module.sqs.queue_arn
  description = "Dev booking queue ARN"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "Dev ECR repository URL"
}

output "app_secret_arn" {
  value       = module.secrets.secret_arn
  description = "Dev application runtime secret ARN"
}

output "app_secret_name" {
  value       = module.secrets.secret_name
  description = "Dev application runtime secret name"
}
