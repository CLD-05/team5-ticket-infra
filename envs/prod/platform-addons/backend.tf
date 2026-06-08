terraform {
  backend "s3" {
    bucket         = "team5-ticket-tfstate-prod"
    key            = "prod/platform-addons/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "team5-ticket-tfstate-lock"
    encrypt        = true
  }
}
