provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Team        = "team5"
      Environment = "dev"
      Project     = "ticket-platform"
      Owner       = "team5"
    }
  }
}

# =====================================
# EKS Cluster Information
# =====================================

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# =====================================
# Kubernetes Provider
# =====================================

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.cluster.token
}

# =====================================
# Helm Provider
# =====================================

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

# =====================================
# Namespaces
# =====================================

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# =====================================
# ArgoCD
# =====================================

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# =====================================
# StorageClass
# =====================================

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}
