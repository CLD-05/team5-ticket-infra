terraform {
  backend "s3" {
    bucket       = "team5-ticket-tfstate-dev"
    key          = "dev/infra/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
