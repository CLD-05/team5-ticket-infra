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
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# =====================================
# ArgoCD Bootstrap
# =====================================

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

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
# GitOps Ownership Boundary
# =====================================
#
# prod/platform-addons는 ArgoCD 자체 설치까지만 담당.
# AWS Load Balancer Controller, External Secrets Operator, ExternalDNS,
# KEDA, Prometheus 등 Kubernetes addon과 ticket-service 배포 manifest는
# config repo를 단일 진실 공급원(SSoT)으로 두고 ArgoCD가 관리.
