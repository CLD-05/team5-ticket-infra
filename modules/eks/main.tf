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
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = true

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
    aws-ebs-csi-driver = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  eks_managed_node_groups = {
    app = {
      name            = "team5-${var.environment}-eks-app-ng"
      use_name_prefix = false

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types

      desired_size = var.node_desired_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size

      iam_role_name                 = "team5-${var.environment}-node-group"
      iam_role_use_name_prefix      = false
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
        Name        = "team5-${var.environment}-node-group"
        Team        = "team5"
        Environment = var.environment
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

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                     = "team5-${var.environment}-ebs-csi"
  role_permissions_boundary_arn = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
  policy_name_prefix            = "team5-"
  attach_ebs_csi_policy         = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
