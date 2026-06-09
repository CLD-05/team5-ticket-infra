terraform {
  backend "s3" {
    bucket       = "tfstate-lionkdt5-team5"
    key          = "prod/infra/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
