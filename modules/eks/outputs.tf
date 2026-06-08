output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS Cluster Name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS Control Plane endpoint"
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "Security group automatically generated for EKS worker nodes"
}

output "lbc_role_arn" {
  value       = aws_iam_role.lbc.arn
  description = "The ARN of the AWS Load Balancer Controller Pod Identity role"
}

output "eso_role_arn" {
  value       = aws_iam_role.eso.arn
  description = "The ARN of the External Secrets Operator Pod Identity role"
}

output "external_dns_role_arn" {
  value       = aws_iam_role.external_dns.arn
  description = "The ARN of the ExternalDNS Pod Identity role"
}
