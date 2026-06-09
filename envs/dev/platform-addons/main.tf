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

resource "kubernetes_namespace" "ingress_system" {
  metadata {
    name = "ingress-system"
  }
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "ticket-app"
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
# AWS Load Balancer Controller
# =====================================

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = kubernetes_namespace.ingress_system.metadata[0].name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    yamlencode({
      clusterName = var.cluster_name

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.ingress_system
  ]
}

# =====================================
# External Secrets Operator
# =====================================

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  values = [
    yamlencode({
      installCRDs = true

      serviceAccount = {
        create = true
        name   = "external-secrets"
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.external_secrets
  ]
}

# =====================================
# ExternalDNS
# =====================================

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  values = [
    yamlencode({
      provider = {
        name = "aws"
      }

      policy = "sync"

      serviceAccount = {
        create = true
        name   = "external-dns"
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.external_dns
  ]
}

# =====================================
# AWS EBS CSI Driver
# =====================================

resource "helm_release" "aws_ebs_csi_driver" {
  name      = "aws-ebs-csi-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  values = [
    yamlencode({
      controller = {
        replicaCount = 2
      }
    })
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

  depends_on = [
    helm_release.aws_ebs_csi_driver
  ]
}
