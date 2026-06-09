output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "lbc_iam_role_arn" {
  value = aws_iam_role.lbc.arn
}

output "eso_iam_role_arn" {
  value = aws_iam_role.eso.arn
}

output "external_dns_iam_role_arn" {
  value = aws_iam_role.external_dns.arn
}
