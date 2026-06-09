variable "environment" {
  type        = string
  description = "Target environment (dev/prod)"
}

variable "project_name" {
  type        = string
  description = "Project name used for standard tags"
}

variable "queue_name" {
  type        = string
  description = "Booking queue name suffix"
  default     = "booking-queue"
}

variable "dlq_name" {
  type        = string
  description = "Dead letter queue name suffix"
  default     = "booking-dlq"
}

variable "delay_seconds" {
  type        = number
  description = "Seconds to delay delivery of new SQS messages"
  default     = 0
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "Seconds a consumed message stays invisible to other consumers"
  default     = 30
}

variable "message_retention_seconds" {
  type        = number
  description = "Seconds to retain booking messages"
  default     = 345600
}

variable "dlq_message_retention_seconds" {
  type        = number
  description = "Seconds to retain failed booking messages in DLQ"
  default     = 1209600
}

variable "max_receive_count" {
  type        = number
  description = "Number of failed receives before moving a message to DLQ"
  default     = 5
}
