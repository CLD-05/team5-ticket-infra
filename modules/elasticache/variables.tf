variable "environment" {
  type        = string
  description = "Target environment (dev/prod)"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ElastiCache subnet group (private subnets)"
}

variable "redis_node_type" {
  type        = string
  description = "Node type for Redis"
}

variable "redis_num_cache_clusters" {
  type        = number
  description = "Number of cache nodes (replication groups)"
}

variable "eks_node_sg_id" {
  type        = string
  description = "Security group ID of the EKS worker nodes"
}

variable "bastion_sg_id" {
  type        = string
  description = "Security group ID of the Bastion host"
}
