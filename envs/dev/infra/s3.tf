module "s3_poster" {
  source = "../../../modules/s3"

  bucket_name = "team5-dev-poster-bucket"
  environment = var.environment
}

output "s3_poster_bucket_name" {
  value       = module.s3_poster.bucket_name
  description = "Dev S3 poster bucket name"
}
