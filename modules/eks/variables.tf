variable "team" {
  type        = string
  default     = "team5"
  description = "팀 식별자"
}

variable "environment" {
  type        = string
  description = "배포 환경"
}

variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "AWS 리전"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "프라이빗 서브넷 ID 리스트"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "EKS 퍼블릭 엔드포인트 활성화 여부 (dev=true, prod=false)"
}

variable "node_desired_size" {
  type        = number
  description = "Managed Node Group 원하는 노드 수"
}

variable "node_min_size" {
  type        = number
  description = "Managed Node Group 최소 노드 수"
}

variable "node_max_size" {
  type        = number
  description = "Managed Node Group 최대 노드 수"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Managed Node Group 인스턴스 타입 리스트"
}

variable "bastion_role_arn" {
  type        = string
  description = "배스천 호스트 IAM 역할 ARN"
}

variable "team_member_user_arns" {
  type        = list(string)
  description = "팀원 IAM 사용자 ARN 리스트"
}
