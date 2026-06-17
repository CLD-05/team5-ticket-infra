resource "aws_sqs_queue" "booking_dlq" {
  name                      = var.fifo_queue ? "team5-${var.environment}-${var.dlq_name}.fifo" : "team5-${var.environment}-${var.dlq_name}"
  message_retention_seconds = var.dlq_message_retention_seconds
  fifo_queue                = var.fifo_queue

  tags = {
    Name        = var.fifo_queue ? "team5-${var.environment}-${var.dlq_name}.fifo" : "team5-${var.environment}-${var.dlq_name}"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}

resource "aws_sqs_queue" "booking_queue" {
  name                        = var.fifo_queue ? "team5-${var.environment}-${var.queue_name}.fifo" : "team5-${var.environment}-${var.queue_name}"
  delay_seconds               = var.delay_seconds
  message_retention_seconds   = var.message_retention_seconds
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.booking_dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name        = var.fifo_queue ? "team5-${var.environment}-${var.queue_name}.fifo" : "team5-${var.environment}-${var.queue_name}"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}
