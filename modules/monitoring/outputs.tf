output "keda_irsa_role_arn" {
  value       = aws_iam_role.keda.arn
  description = "keda-operator ServiceAccount에 eks.amazonaws.com/role-arn 으로 annotate 할 값 (keda.values.yaml에 치환)"
}

output "keda_irsa_role_name" {
  value = aws_iam_role.keda.name
}

output "yace_irsa_role_arn" {
  value       = aws_iam_role.yace.arn
  description = "yace.yaml의 serviceAccount.annotations role-arn에 넣을 값"
}

output "cluster_autoscaler_irsa_role_arn" {
  value       = aws_iam_role.cluster_autoscaler.arn
  description = "cluster-autoscaler ServiceAccount에 eks.amazonaws.com/role-arn 으로 annotate 할 값 (cluster-autoscaler.yaml에 치환)"
}
