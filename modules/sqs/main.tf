resource "aws_sqs_queue" "booking_dlq" {
  name                      = "team5-${var.environment}-${var.dlq_name}"
  message_retention_seconds = var.dlq_message_retention_seconds

  tags = {
    Name        = "team5-${var.environment}-${var.dlq_name}"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}

resource "aws_sqs_queue" "booking_queue" {
  name                       = "team5-${var.environment}-${var.queue_name}"
  delay_seconds              = var.delay_seconds
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.booking_dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name        = "team5-${var.environment}-${var.queue_name}"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}
