variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project_name" {
  type    = string
  default = "team5-ticket"
}

variable "environment" {
  type    = string
  default = "dev"
}

# Network Variables
variable "vpc_cidr" {
  type    = string
  default = "10.5.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.5.0.0/24", "10.5.1.0/24", "10.5.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.5.16.0/20", "10.5.32.0/20", "10.5.48.0/20"]
}

variable "database_subnet_cidrs" {
  type    = list(string)
  default = ["10.5.240.0/24", "10.5.241.0/24", "10.5.242.0/24"]
}

variable "enable_multi_nat" {
  type    = bool
  default = false
}

# EKS Variables
variable "cluster_name" {
  type    = string
  default = "team5-dev-eks"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 5
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

# RDS Variables
variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "db_backup_retention" {
  type    = number
  default = 1
}

# Redis Variables
variable "redis_node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "redis_num_cache_clusters" {
  type    = number
  default = 1
}

# Access Control Variables
variable "team_member_user_arns" {
  type = map(string)
  default = {
    "jehoon"  = "arn:aws:iam::123456789012:user/team5-jehoon"
    "sihyun"  = "arn:aws:iam::123456789012:user/team5-sihyun"
    "jihyun"  = "arn:aws:iam::123456789012:user/team5-jihyun"
    "sungmin" = "arn:aws:iam::123456789012:user/team5-sungmin"
    "hyeonsu" = "arn:aws:iam::123456789012:user/team5-hyeonsu"
  }
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = []
}
