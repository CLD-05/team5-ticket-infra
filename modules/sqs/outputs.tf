output "queue_name" {
  value       = aws_sqs_queue.booking_queue.name
  description = "Booking queue name"
}

output "queue_url" {
  value       = aws_sqs_queue.booking_queue.url
  description = "Booking queue URL"
}

output "queue_arn" {
  value       = aws_sqs_queue.booking_queue.arn
  description = "Booking queue ARN"
}

output "dlq_name" {
  value       = aws_sqs_queue.booking_dlq.name
  description = "Booking DLQ name"
}

output "dlq_url" {
  value       = aws_sqs_queue.booking_dlq.url
  description = "Booking DLQ URL"
}

output "dlq_arn" {
  value       = aws_sqs_queue.booking_dlq.arn
  description = "Booking DLQ ARN"
}
