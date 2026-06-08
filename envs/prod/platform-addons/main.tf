provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Team        = "team5"
      Environment = "prod"
      Project     = "ticket-platform"
      Owner       = "team5"
    }
  }
}

# Fetch the EKS cluster dynamically
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Initialize Kubernetes provider using EKS dynamic endpoints
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Initialize Helm provider using EKS dynamic endpoints
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# --- Placeholders for Platform Addons (Helm Releases) ---
# Example: ArgoCD, AWS Load Balancer Controller, KEDA, ESO, Prometheus, etc.
# These will be synced from your Git config repo via GitOps or deployed here.
