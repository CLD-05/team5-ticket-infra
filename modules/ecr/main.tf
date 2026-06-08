resource "aws_ecr_repository" "app" {
  name                 = "team5-${var.environment}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "team5-${var.environment}-app-ecr"
    Team = "team5"
  }
}
