variable "team" {
  type        = string
  default     = "team5"
  description = "팀 식별자"
}

variable "environment" {
  type        = string
  description = "배포 환경"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.35"
  description = "EKS Kubernetes 버전"
}

variable "endpoint_public_access" {
  type        = bool
  description = "EKS 퍼블릭 엔드포인트 활성화 여부 (dev=true, prod=false)"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "EKS 프라이빗 엔드포인트 활성화 여부"
}
