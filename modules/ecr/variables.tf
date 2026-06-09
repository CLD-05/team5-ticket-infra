variable "environment" {
  type        = string
  description = "Target environment (dev/prod)"
}

variable "project_name" {
  type        = string
  description = "Project name used for standard tags"
}

variable "image_tag_mutability" {
  type        = string
  description = "ECR image tag mutability setting"
  default     = "MUTABLE"
}

variable "max_tagged_image_count" {
  type        = number
  description = "Maximum number of tagged images to keep"
  default     = 30
}
