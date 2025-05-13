# VPC
resource "aws_vpc" "custom-vpc" {
  cidr_block = var.vpc_cidrs
  tags = {
    Name = "${var.name_tag}--vpc"
  }
}

# Public subnet (only one)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom-vpc.id
  cidr_block              = var.public_subnet_cidrs
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.name_tag}--public subnet"
  }
}

# Creating 2 private subnets to house RDS instances
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.custom-vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.subnet_availability_zones[count.index]
  tags = {
    Name : "${var.name_tag}--private subnet--${count.index + 1}"
  }
}

# To group together the two private subnets for RDS deployment
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.name_tag}--db subnet group"
  subnet_ids  = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
  description = var.subnet_group_description
}

# To allow the local network to communicate with the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom-vpc.id

  tags = {
    Name = "${var.name_tag}--igw"
  }
}

# To route local network traffic to the internet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom-vpc.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name_tag}--public route table"
  }
}

# To associate a route table with our public subnet
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# For our NAT Gateway. This is to ensure a static, public IPv4 address for outbound connectivity
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# To connect instance in a private subnet to the internet
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name : "${var.name_tag}--ngw"
  }
  depends_on = [aws_internet_gateway.igw]
}

# To route traffic from the private subnet to the internet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${var.name_tag}--private route table"
  }
}

# To associate the private route table with the first of our private subnets
resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.private_route_table.id
}

# To associate the private route table with the second of our private subnets
resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.private_subnet[1].id
  route_table_id = aws_route_table.private_route_table.id
}




