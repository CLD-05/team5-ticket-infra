variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "environment" {
  type        = string
  description = "The deployment environment"
}

resource "aws_s3_bucket" "poster" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Public Access Block 해제 (Public read 허용을 위해 필수)
resource "aws_s3_bucket_public_access_block" "poster" {
  bucket = aws_s3_bucket.poster.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy - Public Read Allow (모든 사람이 포스터 이미지를 조회할 수 있게)
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.poster.id
  depends_on = [aws_s3_bucket_public_access_block.poster]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.poster.arn}/*"
      }
    ]
  })
}

# CORS 설정 (브라우저에서 직접 Fetch 가능하도록)
resource "aws_s3_bucket_cors_configuration" "poster" {
  bucket = aws_s3_bucket.poster.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

output "bucket_name" {
  value = aws_s3_bucket.poster.id
}
