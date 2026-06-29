variable "environment" {
  type        = string
  description = "Target environment (dev/prod)"
}

variable "project_name" {
  type        = string
  description = "Project name used for standard tags"
}

variable "db_endpoint" {
  type        = string
  description = "RDS endpoint including host and port"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database username"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "redis_endpoint" {
  type        = string
  description = "Redis primary endpoint address"
}

variable "redis_port" {
  type        = number
  description = "Redis port"
  default     = 6379
}

variable "sqs_queue_url" {
  type        = string
  description = "Booking queue URL"
}

variable "sqs_queue_arn" {
  type        = string
  description = "Booking queue ARN"
}

variable "poster_cdn_base_url" {
  type        = string
  description = "Base URL for poster images served through CloudFront"
  default     = ""
}

variable "db_replica_endpoint" {
  description = "RDS Read Replica endpoint (prod only, empty string if not exists)"
  type        = string
  default     = ""
}
