resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/team5-${var.environment}-cluster/cluster"
  retention_in_days = 30
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "team5-${var.environment}-eks"
  cluster_version = "1.35"

  iam_role_permissions_boundary = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_endpoint_public_access  = var.endpoint_public_access
  cluster_endpoint_private_access = var.endpoint_private_access

  authentication_mode = "API_AND_CONFIG_MAP"

  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = ["api", "authenticator", "controllerManager", "scheduler"]

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
      ami_type       = "AL2_x86_64"
      instance_types = var.node_instance_types

      desired_size = var.node_desired_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size

      iam_role_permissions_boundary = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }

      labels = {
        role = "general"
      }

      tags = {
        Name = "team5-${var.environment}-node-group"
      }
    }
  }

  tags = {
    Name = "team5-${var.environment}-eks"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_cluster
  ]
}
