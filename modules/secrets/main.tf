resource "random_password" "jwt" {
  length           = 48
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "app" {
  name        = "team5/${var.environment}/ticket-app"
  description = "Runtime configuration for the team5 ticketing application"

  tags = {
    Name        = "team5-${var.environment}-ticket-app-secret"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    SPRING_DATASOURCE_URL      = "jdbc:mysql://${var.db_endpoint}/${var.db_name}?useUnicode=true&allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8"
    SPRING_DATASOURCE_USERNAME = var.db_username
    SPRING_DATASOURCE_PASSWORD = var.db_password
    SPRING_DATA_REDIS_HOST     = var.redis_endpoint
    SPRING_DATA_REDIS_PORT     = tostring(var.redis_port)
    AWS_SQS_BOOKING_QUEUE_URL  = var.sqs_queue_url
    AWS_SQS_BOOKING_QUEUE_ARN  = var.sqs_queue_arn
    JWT_SECRET                 = random_password.jwt.result
  })
}
