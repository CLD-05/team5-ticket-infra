module "waf" {
  source       = "../../../modules/waf"
  environment  = var.environment
  project_name = var.project_name
  rate_limit   = var.waf_rate_limit
}
