output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS 클러스터 이름"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS 클러스터 엔드포인트 URL"
}

output "cluster_version" {
  value       = module.eks.cluster_version
  description = "EKS 쿠버네티스 버전"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "EKS 클러스터 OIDC ID 공급자 ARN"
}

output "oidc_provider_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "EKS 클러스터 OIDC 발급자 URL"
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "EKS 클러스터 보안 그룹 ID"
}

output "node_group_id" {
  value       = [for ng in module.eks.eks_managed_node_groups : ng.node_group_id]
  description = "EKS Managed Node Group ID 리스트"
}

output "lbc_iam_role_arn" {
  value       = aws_iam_role.lbc.arn
  description = "AWS Load Balancer Controller용 IAM 역할 ARN"
}

output "eso_iam_role_arn" {
  value       = aws_iam_role.eso.arn
  description = "External Secrets Operator용 IAM 역할 ARN"
}

output "external_dns_iam_role_arn" {
  value       = aws_iam_role.external_dns.arn
  description = "ExternalDNS용 IAM 역할 ARN"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "EKS 클러스터 인증서 데이터"
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "EKS Managed Node Group 보안 그룹 ID"
}
