# imports.tf
# EKS app 노드그룹 관련 IAM 리소스 및 활성 Route 53 영역 state 가져오기

import {
  to = module.eks.module.eks.module.eks_managed_node_group["app"].aws_iam_role.this[0]
  id = "team5-prod-node-group"
}

import {
  to = module.eks.module.eks.module.eks_managed_node_group["app"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]
  id = "team5-prod-node-group/arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

import {
  to = module.eks.module.eks.module.eks_managed_node_group["app"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]
  id = "team5-prod-node-group/arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

import {
  to = module.eks.module.eks.module.eks_managed_node_group["app"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]
  id = "team5-prod-node-group/arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Route 53 활성 영역 및 레코드 가져오기용 import 블록
import {
  to = aws_route53_zone.prod_domain
  id = "Z01580172CZSVI4ZGPE76"
}

import {
  to = aws_route53_record.team5
  id = "Z01580172CZSVI4ZGPE76_team5.cloud-infra.shop_A"
}