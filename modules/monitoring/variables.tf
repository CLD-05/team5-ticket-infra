variable "name_prefix" {
  type        = string
  description = "리소스 이름 접두사 (예: team5-dev)"
}

variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC provider ARN (eks 모듈 output에서 주입)"
}

variable "oidc_provider_url" {
  type        = string
  description = "EKS OIDC issuer URL (eks 모듈 oidc_provider_url 그대로 주입 가능, https:// 스킴은 모듈 내부에서 제거)"
}

variable "booking_queue_arn" {
  type        = string
  description = "KEDA가 폴링할 booking-queue SQS ARN (sqs 모듈 output에서 주입)"
}

variable "keda_namespace" {
  type        = string
  description = "KEDA 설치 네임스페이스"
  default     = "keda"
}

variable "keda_service_account" {
  type        = string
  description = "KEDA operator ServiceAccount 이름"
  default     = "keda-operator"
}

variable "monitoring_namespace" {
  type        = string
  description = "관측 스택(YACE 포함) 네임스페이스"
  default     = "monitoring"
}

variable "yace_service_account" {
  type        = string
  description = "YACE exporter ServiceAccount 이름 (yace.yaml helm values와 일치시킬 것)"
  default     = "yace"
}

variable "tags" {
  type    = map(string)
  default = {}
}
