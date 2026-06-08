module "elasticache" {
  source = "../../../modules/elasticache"

  environment              = var.environment
  vpc_id                   = module.network.vpc_id
  subnet_ids               = module.network.private_subnet_ids
  redis_node_type          = var.redis_node_type
  redis_num_cache_clusters = var.redis_num_cache_clusters
  eks_node_sg_id           = module.eks.node_security_group_id
  bastion_sg_id            = module.bastion.bastion_sg_id
}
