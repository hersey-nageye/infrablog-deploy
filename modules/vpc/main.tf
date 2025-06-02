# Create the main VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vpc-${var.environment}"
    }
  )
}

# One public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.subnet_availability_zones[0]
  map_public_ip_on_launch = true
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-subnet-${var.environment}-a"
    }
  )
}

# Two private subnets (for RDS)
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.subnet_availability_zones[0]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-subnet-${var.environment}-a"
    }
  )
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.subnet_availability_zones[1]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-subnet-${var.environment}-b"
    }
  )
}

# Group private subnets for RDS deployment
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.subnet_group_name}-${var.environment}"
  subnet_ids  = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  description = var.subnet_group_description
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-subnet-group-${var.environment}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-igw-${var.environment}"
    }
  )
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

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

# Associate public subnet with public route table
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Private route table (shared for both private subnets, no NAT)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  # Optional: add local routes if needed; no NAT for dev

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-route-table-${var.environment}"
    }
  )
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_rta_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}
