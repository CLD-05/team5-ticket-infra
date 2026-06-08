module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "team5-${var.environment}-eks"
  cluster_version = "1.35"

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Endpoint Access Hardening: Public access enabled for Dev, restricted for Prod (private-only or via Bastion)
  cluster_endpoint_public_access  = var.environment == "prod" ? false : true
  cluster_endpoint_private_access = true

  # Set authentication mode to support both ConfigMap and the modern Access Entry API
  authentication_mode = "API_AND_CONFIG_MAP"

  # Core addons needed for the cluster data plane
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    eks-pod-identity-agent = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  eks_managed_node_groups = {
    general = {
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      instance_types = var.node_instance_types
      capacity_type  = var.environment == "prod" ? "ON_DEMAND" : "ON_DEMAND" # Can mix Spot/On-Demand if needed

      labels = {
        role = "general"
      }
    }
  }

  tags = {
    Team        = "team5"
    Environment = var.environment
  }
}

# --- EKS Access Entries (v2/v3 Authentication & Authorization) ---

# 1. Bastion Host Access Entry (v2: Bastion Role gets Cluster Admin)
resource "aws_eks_access_entry" "bastion" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.bastion.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.bastion.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

# 2. Individual Team Member Access Entries (v3: Direct mapping of IAM Users to EKS for auditability)
resource "aws_eks_access_entry" "members" {
  for_each      = var.team_member_user_arns
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "members_admin" {
  for_each      = var.team_member_user_arns
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

# Outputs
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}
