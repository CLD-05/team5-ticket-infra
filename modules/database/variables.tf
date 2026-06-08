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
  description = "Subnet IDs for DB subnet group (dedicated database subnets)"
}

variable "db_instance_class" {
  type        = string
  description = "Instance class for RDS"
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ failover replica"
}

variable "db_deletion_protection" {
  type        = bool
  description = "Enable RDS deletion protection"
}

variable "db_skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot during destroy"
}

variable "db_backup_retention" {
  type        = number
  description = "Days of automated backups to retain"
}

variable "eks_node_sg_id" {
  type        = string
  description = "Security group ID of the EKS worker nodes"
}

variable "bastion_sg_id" {
  type        = string
  description = "Security group ID of the Bastion host"
}
