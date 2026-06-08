# ElastiCache Redis Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "team5-${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "team5-${var.environment}-redis-subnet-group"
    Team = "team5"
  }
}

# ElastiCache Redis Replication Group
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "team5-${var.environment}-redis"
  description                = "Redis cluster for token-bucket rate limiting and seat locks"
  node_type                  = var.redis_node_type
  num_cache_clusters         = var.redis_num_cache_clusters
  automatic_failover_enabled = var.redis_num_cache_clusters > 1 ? true : false
  engine                     = "redis"
  engine_version             = "7.0"

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  transit_encryption_enabled = false
  at_rest_encryption_enabled = true

  tags = {
    Name = "team5-${var.environment}-redis"
    Team = "team5"
  }
}

# Security Group for Redis
resource "aws_security_group" "redis" {
  name        = "team5-${var.environment}-redis-sg"
  description = "Security group for Redis cluster allowing only EKS workers and Bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
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
    Name = "team5-${var.environment}-redis-sg"
    Team = "team5"
  }
}
