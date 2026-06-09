output "secret_arn" {
  value       = aws_secretsmanager_secret.app.arn
  description = "Application runtime secret ARN"
}

output "secret_name" {
  value       = aws_secretsmanager_secret.app.name
  description = "Application runtime secret name"
}
