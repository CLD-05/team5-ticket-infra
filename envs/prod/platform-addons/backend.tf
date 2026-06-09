terraform {
  backend "s3" {
    bucket       = "team5-ticket-tfstate-prod"
    key          = "prod/platform-addons/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
