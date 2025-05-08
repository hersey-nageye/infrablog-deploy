output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom-vpc.id
}

output "public_subnet_id" {
  description = "The ID for the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_ids" {
  description = "The IDs for the private subnets"
  value       = [for subnet in aws_aws_subnet.private_subnet : subnet.id]
}

output "aws_db_subnet_group_id" {
  description = "ID for the db subnet group"
  value       = aws_db_subnet_group.db_subnet_group.id
}

output "igw_id" {
  description = "ID for the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "rt_id" {
  description = "ID for the route table"
  value       = aws_route_table.rt.id
}

output "eip_id" {
  description = "ID for the elastic IP"
  value       = aws_eip.nat_eip.id
}

output "ngw_id" {
  description = "ID for the NAT gateway"
  value       = aws_nat_gateway.ngw.id
}

output "private_rt_id" {
  description = "ID for the private route table"
  value       = aws_route_table.private_route_table.id
}

