output "bastion_role_arn" {
  value       = aws_iam_role.bastion.arn
  description = "The ARN of the Bastion IAM Role"
}

output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "The ID of the Bastion Security Group"
}

output "bastion_instance_id" {
  value       = aws_instance.bastion.id
  description = "The instance ID of the Bastion host"
}
