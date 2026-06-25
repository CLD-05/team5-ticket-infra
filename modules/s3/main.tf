variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g. dev, prod)"
}

resource "aws_s3_bucket" "poster_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "poster_bucket" {
  bucket = aws_s3_bucket.poster_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "poster_bucket" {
  bucket     = aws_s3_bucket.poster_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.poster_bucket]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicReadPosters"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.poster_bucket.arn}/posters/*"
      }
    ]
  })
}

output "bucket_name" {
  value = aws_s3_bucket.poster_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.poster_bucket.arn
}
