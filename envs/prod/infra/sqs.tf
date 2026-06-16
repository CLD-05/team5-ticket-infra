module "sqs" {
  source = "../../../modules/sqs"

  environment                 = var.environment
  project_name                = var.project_name
  message_retention_seconds   = var.sqs_message_retention_seconds
  max_receive_count           = var.sqs_max_receive_count
  fifo_queue                  = true
  content_based_deduplication = true
}
