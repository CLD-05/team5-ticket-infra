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

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      Team        = "team5"
      Environment = var.environment
      Project     = var.project_name
      Owner       = "team5"
    }
  }
}
