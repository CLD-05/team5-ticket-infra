module "network" {
  source = "../../../modules/network"

  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_multi_nat      = var.enable_multi_nat
}
