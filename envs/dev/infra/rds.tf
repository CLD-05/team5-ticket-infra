module "database" {
  source = "../../../modules/database"

  environment            = var.environment
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.database_subnet_ids
  db_instance_class      = var.db_instance_class
  db_multi_az            = var.db_multi_az
  db_deletion_protection = var.db_deletion_protection
  db_skip_final_snapshot = var.db_skip_final_snapshot
  db_backup_retention    = var.db_backup_retention
  eks_node_sg_id         = module.eks.node_security_group_id
  bastion_sg_id          = module.bastion.bastion_sg_id
}
