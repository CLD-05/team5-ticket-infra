variable "environment" {
  type        = string
  description = "배포 환경 (dev / prod)"
}

variable "is_prod" {
  type        = bool
  default     = false
  description = "운영 환경(prod) 여부 판별값"
}

variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "AWS 리전 주소"
}

variable "vpc_id" {
  type        = string
  description = "인프라 VPC ID"
}

variable "cluster_name" {
  type        = string
  description = "EKS 클러스터 이름"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.35"
  description = "EKS 쿠버네티스 버전"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "EKS 퍼블릭 엔드포인트 활성화 여부"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "프라이빗 서브넷 ID 리스트"
}

variable "subnet_ids" {
  type        = list(string)
  description = "기존 서브넷 ID 연동용"
}

variable "desired_size" {
  type        = number
  description = "노드 그룹 원하는 노드 수"
}

variable "min_size" {
  type        = number
  description = "노드 그룹 최소 노드 수"
}

variable "max_size" {
  type        = number
  description = "노드 그룹 최대 노드 수"
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

variable "instance_types" {
  type        = list(string)
  description = "노드 인스턴스 타입 리스트"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Managed Node Group 인스턴스 타입 리스트"
}

variable "bastion_role_arn" {
  type        = string
  description = "배스천 호스트 IAM 역할 ARN"
}

variable "node_security_group_ids" {
  type        = list(string)
  description = "EKS 노드 보안 그룹 ID 리스트"
}

variable "rds_security_group_id" {
  type        = string
  description = "데이터베이스(RDS) 보안 그룹 ID"
}

variable "redis_security_group_id" {
  type        = string
  description = "캐시(Redis) 보안 그룹 ID"
}

variable "team_member_user_arns" {
  type = map(object({
    arn  = string
    role = string
  }))
  description = "팀원 IAM User ARN 및 역할"
  default     = {}
}
