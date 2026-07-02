# Temporary import blocks to reconcile state with existing AWS resources.
# These node groups already exist in AWS but were lost from Terraform state
# due to a partial apply failure. After a successful apply, remove this file.

import {
  to = module.eks.module.eks.module.eks_managed_node_group["app"].aws_eks_node_group.this[0]
  id = "team5-prod-eks:team5-prod-eks-app-ng"
}

import {
  to = module.eks.module.eks.module.eks_managed_node_group["runner"].aws_eks_node_group.this[0]
  id = "team5-prod-eks:team5-prod-eks-runner-ng"
}
