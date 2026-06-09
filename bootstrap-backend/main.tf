provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "terraform_state_dev" {
  bucket = "team5-ticket-tfstate-dev"

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
  bucket = "team5-ticket-tfstate-prod"

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

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "team5-ticket-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
