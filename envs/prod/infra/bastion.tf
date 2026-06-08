# Bastion Security Group
resource "aws_security_group" "bastion" {
  name        = "team5-${var.environment}-bastion-sg"
  description = "Security group for Bastion host (SSM-only, no open SSH by default)"
  vpc_id      = aws_vpc.main.id

  # Dynamic SSH access only if allowed_ssh_cidrs is provided
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidrs
    }
  }

  # Outbound access to allow SSM agent to communicate with AWS endpoints and download tools
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "team5-${var.environment}-bastion-sg"
    Team = "team5"
  }
}

# IAM Role for Bastion (SSM Managed)
resource "aws_iam_role" "bastion" {
  name = "team5-${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "team5-${var.environment}-bastion-role"
    Team = "team5"
  }
}

# Attach SSM Managed Policy
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile for EC2
resource "aws_iam_instance_profile" "bastion" {
  name = "team5-${var.environment}-bastion-profile"
  role = aws_iam_role.bastion.name
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Bastion Host Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  # Enable metadata service version 2 (IMDSv2) for security hardening
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "team5-${var.environment}-bastion"
    Team = "team5"
  }
}
