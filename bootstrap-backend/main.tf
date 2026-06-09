provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tfstate-lionkdt5-team5"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Team       = "team5"
    Project    = "final"
    purpose    = "tfstate"
    managed-by = "opsmanager"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
