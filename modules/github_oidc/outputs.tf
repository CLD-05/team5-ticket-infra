output "gha_role_arn" {
  value       = aws_iam_role.gha.arn
  description = "The ARN of the GitHub Actions OIDC IAM Role"
}
