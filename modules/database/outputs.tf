output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "The database connection endpoint"
}

output "db_address" {
  value       = aws_db_instance.main.address
  description = "The database address"
}

output "db_name" {
  value       = aws_db_instance.main.db_name
  description = "The database name"
}

output "db_username" {
  value       = aws_db_instance.main.username
  description = "The database master username"
  sensitive   = true
}

output "db_password" {
  value       = random_password.db.result
  description = "The generated database master password"
  sensitive   = true
}

output "db_security_group_id" {
  value       = aws_security_group.rds.id
  description = "The RDS security group ID"
}
