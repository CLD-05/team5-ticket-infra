output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "The database connection endpoint"
}

output "db_address" {
  value       = aws_db_instance.main.address
  description = "The database address"
}
