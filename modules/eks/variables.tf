variable "environment" {
  type        = string
  description = "Target environment (dev/prod)"
}

variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where EKS is deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the EKS worker nodes"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Whether to enable EKS Control Plane public endpoint access"
}

variable "node_desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "node_min_size" {
  type        = number
  description = "Minimum number of worker nodes"
}

variable "node_max_size" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the worker nodes"
}

variable "bastion_role_arn" {
  type        = string
  description = "The ARN of the Bastion Host IAM Role to assign access"
}

variable "team_member_user_arns" {
  type        = map(string)
  description = "Map of personal IAM User ARNs for direct cluster mappings"
}
