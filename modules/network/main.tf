resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "team5-${var.environment}-vpc"
    Team = "team5"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "team5-${var.environment}-igw"
    Team = "team5"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name                     = "team5-${var.environment}-subnet-pub-${var.azs[count.index]}"
    Team                     = "team5"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "team5-${var.environment}-subnet-pri-${var.azs[count.index]}"
    Team                              = "team5"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "database" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "team5-${var.environment}-subnet-db-${var.azs[count.index]}"
    Team = "team5"
  }
}

resource "aws_eip" "nat" {
  count  = var.enable_multi_nat ? length(var.azs) : 1
  domain = "vpc"

  tags = {
    Name = "team5-${var.environment}-nat-eip-${count.index + 1}"
    Team = "team5"
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_multi_nat ? length(var.azs) : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "team5-${var.environment}-nat-${count.index + 1}"
    Team = "team5"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "team5-${var.environment}-public-rt"
    Team = "team5"
  }
}

resource "aws_route_table" "private" {
  count  = var.enable_multi_nat ? length(var.azs) : 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "team5-${var.environment}-private-rt-${count.index + 1}"
    Team = "team5"
  }
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "team5-${var.environment}-db-rt"
    Team = "team5"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_multi_nat ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

resource "aws_route_table_association" "database" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
