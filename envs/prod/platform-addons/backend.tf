terraform {
  backend "s3" {
    bucket       = "tfstate-lionkdt5-team5-prod"
    key          = "team5/prod/platform-addons/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
