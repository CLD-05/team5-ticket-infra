# KMS Key for RDS Storage Encryption
resource "aws_kms_key" "rds" {
  description             = "KMS Key for RDS database encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "team5-${var.environment}-rds-key"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/team5-${var.environment}-rds-key"
  target_key_id = aws_kms_key.rds.key_id
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "team5-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "team5-${var.environment}-db-subnet-group"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier            = "team5-${var.environment}-rds"
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  engine                = "mysql"
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  db_name               = var.db_name
  username              = var.db_username
  password              = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az                  = var.db_multi_az
  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : "team5-${var.environment}-rds-final-snapshot"
  backup_retention_period   = var.db_backup_retention

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  tags = {
    Name        = "team5-${var.environment}-rds"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "team5-${var.environment}-rds-sg"
  description = "Security group for RDS database allowing only EKS workers and Bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      var.eks_node_sg_id,
      var.bastion_sg_id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "team5-${var.environment}-rds-sg"
    Team        = "team5"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "team5"
  }
}
