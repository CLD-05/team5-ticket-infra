# Main SQS Booking Queue
resource "aws_sqs_queue" "booking_queue" {
  name                       = "team5-${var.environment}-booking-queue"
  delay_seconds              = 0
  message_retention_period   = 86400 # 1 day retention
  visibility_timeout_seconds = 30

  tags = {
    Name = "team5-${var.environment}-booking-queue"
    Team = "team5"
  }
}

# Dead Letter Queue (DLQ) for failed booking transactions
resource "aws_sqs_queue" "booking_dlq" {
  name                     = "team5-${var.environment}-booking-dlq"
  message_retention_period = 1209600 # 14 days retention

  tags = {
    Name = "team5-${var.environment}-booking-dlq"
    Team = "team5"
  }
}

# Redrive Policy associating DLQ to the main queue
resource "aws_sqs_queue_redrive_policy" "booking_redrive" {
  queue_url = aws_sqs_queue.booking_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.booking_dlq.arn
    maxReceiveCount     = 3 # Send to DLQ after 3 failures
  })
}
