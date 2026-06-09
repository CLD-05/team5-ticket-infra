resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.team}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.team}-${var.environment}-cluster/cluster"
  retention_in_days = 30
}

resource "aws_eks_cluster" "main" {
  name     = "${var.team}-${var.environment}-eks"
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  enabled_cluster_log_types = ["api", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = []
  }

  tags = {
    Name = "${var.team}-${var.environment}-eks"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks_cluster
  ]
}

resource "aws_eks_cluster" "main" {
  name     = "${var.team}-${var.environment}-eks"
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  enabled_cluster_log_types = ["api", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = []
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
  }

  tags = {
    Name = "${var.team}-${var.environment}-eks"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks_cluster
  ]
}
