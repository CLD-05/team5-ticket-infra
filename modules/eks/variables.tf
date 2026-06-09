variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "team" {
  type    = string
  default = "team5"
}

variable "environment" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.35"
}

variable "endpoint_public_access" {
  type = bool
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "node_security_group_id" {
  type = string
}

variable "node_desired_size" {
  type    = number
  default = var.environment == "prod" ? 3 : 2
}

variable "node_min_size" {
  type    = number
  default = var.environment == "prod" ? 2 : 1
}

variable "node_max_size" {
  type    = number
  default = var.environment == "prod" ? 10 : 5
}

variable "node_instance_types" {
  type    = list(string)
  default = var.environment == "prod" ? ["m6i.large", "c6i.large"] : ["t3.medium"]
}
