module "secrets" {
  source = "../../../modules/secrets"

  environment    = var.environment
  project_name   = var.project_name
  db_endpoint    = module.database.db_endpoint
  db_name        = module.database.db_name
  db_username    = module.database.db_username
  db_password    = module.database.db_password
  redis_endpoint = module.elasticache.redis_endpoint
  redis_port     = module.elasticache.redis_port
  sqs_queue_url  = module.sqs.queue_url
  sqs_queue_arn  = module.sqs.queue_arn
}
