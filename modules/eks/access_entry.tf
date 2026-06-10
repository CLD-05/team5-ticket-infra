resource "aws_eks_access_entry" "bastion" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.bastion_role_arn
  type          = "STANDARD"

  tags = {
    Name = "team5-${var.environment}-bastion"
  }
}

resource "aws_eks_access_policy_association" "bastion" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.bastion_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "team_member" {
  for_each = var.team_member_user_arns

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value.arn
  type          = "STANDARD"

  tags = {
    Name = "team5-${var.environment}-${each.key}"
  }
}

resource "aws_eks_access_policy_association" "team_member_dev" {
  for_each = var.is_prod == false ? var.team_member_user_arns : {}

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "team_member_prod" {
  for_each = var.is_prod == true ? { for member in var.team_member_user_arns : member.arn => member } : {}

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.key

  policy_arn = each.value.role == "admin" ? "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" : (
    each.value.role == "developer" ? "arn:aws:eks::aws:cluster-access-policy/AmazonEKSDeveloperPolicy" :
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  )

  access_scope {
    type       = each.value.role == "admin" ? "cluster" : "namespace"
    namespaces = each.value.role == "admin" ? null : ["default", "app", "monitoring"]
  }
}
