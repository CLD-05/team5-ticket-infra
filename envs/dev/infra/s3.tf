module "s3" {
  source      = "../../../modules/s3"
  bucket_name = "team5-dev-poster-bucket"
  environment = var.environment
}

