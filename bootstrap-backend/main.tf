provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "terraform_state_dev" {
  bucket = "tfstate-lionkdt5-team5"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_dev" {
  bucket = aws_s3_bucket.terraform_state_dev.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "terraform_state_prod" {
  bucket = "tfstate-lionkdt5-team5-prod"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_prod" {
  bucket = aws_s3_bucket.terraform_state_prod.id
  versioning_configuration {
    status = "Enabled"
  }
}
