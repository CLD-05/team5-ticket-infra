provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Team        = "team5"
      Environment = var.environment
      Project     = "ticket-platform"
      Owner       = "team5"
    }
  }
}
