# Create the main VPC
resource "aws_vpc" "custom-vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vpc-${var.environment}"
    }
  )
}

# Create public subnets for high availability (only in staging and production)
resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.custom-vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.public_subnet_azs, count.index)
  map_public_ip_on_launch = true
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-subnet-${var.environment}-${count.index}"
    }
  )
}

# Create private subnets for RDS, Vault and wordpress instances
resource "aws_subnet" "private_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.custom-vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.private_subnet_azs, count.index)
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-subnet-${var.environment}-${count.index}"
    }
  )
}

# Group private subnet group for RDS deployment
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = var.subnet_group_name
  subnet_ids  = [for s in aws_subnet.private_subnet : s.id]
  description = var.subnet_group_description
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-subnet-group-${var.environment}"
    }
  )
}

# Internet Gateway for VPC internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom-vpc.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-igw-${var.environment}"
    }
  )
}

# Route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-route-table-${var.environment}"
    }
  )
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_rta" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT Gateway (only one in dev)
resource "aws_eip" "nat_eip" {
  count  = var.env == "localstack" ? 0 : 1 # Only create EIP in non-localstack environments
  domain = "vpc"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-nat-eip-${var.environment}"
    }
  )
}

# NAT Gateway (only one in dev)
resource "aws_nat_gateway" "ngw" {
  count         = var.env == "localstack" ? 0 : 1 # Only create NAT Gateway in non-localstack environments
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id # Use the first public subnet for NAT Gateway
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-nat-gateway-${var.environment}"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}

# Single route table for private subnets in dev
resource "aws_route_table" "private_rt" {
  # count  = length(var.private_subnet_azs) - To be incorporated back in staging and prod
  vpc_id = aws_vpc.custom-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[0].id # Single NAT Gateway
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-route-table-${var.environment}"
    }
  )
}

# Associate private subnets with the private route table (only one in dev)
resource "aws_route_table_association" "private_rta" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

