variable "environment" {
  type        = string
  description = "Target environment (dev/prod)"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where Bastion is deployed"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID to launch the Bastion host in"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  default     = []
  description = "Allowed CIDR blocks for SSH (rely on SSM if empty)"
}
