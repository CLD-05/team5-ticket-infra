provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Team        = "team5"
      Environment = var.environment
      Project     = var.project_name
      Owner       = "team5"
    }
  }
}
