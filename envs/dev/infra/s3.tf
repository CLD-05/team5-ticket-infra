resource "aws_s3_bucket" "poster_bucket" {
  bucket = "team5-dev-poster-bucket"

  tags = {
    Name        = "team5-dev-poster-bucket"
    Environment = "dev"
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
