output "rds_endpoint" {
  value       = module.database.db_endpoint
  description = "Prod RDS endpoint"
}

output "rds_proxy_endpoint" {
  value       = module.database.db_proxy_endpoint
  description = "Prod RDS Proxy connection endpoint"
}

output "redis_endpoint" {
  value       = module.elasticache.redis_endpoint
  description = "Prod Redis endpoint"
}

output "sqs_booking_queue_url" {
  value       = module.sqs.queue_url
  description = "Prod booking queue URL"
}

output "sqs_booking_queue_arn" {
  value       = module.sqs.queue_arn
  description = "Prod booking queue ARN"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "Prod ECR repository URL"
}

output "app_secret_arn" {
  value       = module.secrets.secret_arn
  description = "Prod application runtime secret ARN"
}

output "app_secret_name" {
  value       = module.secrets.secret_name
  description = "Prod application runtime secret name"
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}

output "poster_cloudfront_distribution_id" {
  value       = module.s3.cloudfront_distribution_id
  description = "Prod poster CloudFront distribution ID"
}

output "poster_cloudfront_domain_name" {
  value       = module.s3.cloudfront_domain_name
  description = "Prod poster CloudFront domain name"
}

output "db_replica_endpoint" {
  value       = module.database.db_replica_endpoint
  description = "Prod RDS Read Replica connection endpoint"
}

output "db_replica_address" {
  value       = module.database.db_replica_address
  description = "Prod RDS Read Replica address"
}
