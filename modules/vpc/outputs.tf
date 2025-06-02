output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}

output "public_subnet_ids" {
  description = "The ID for the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_ids" {
  description = "The IDs for the private subnets"
  value       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "aws_db_subnet_group_id" {
  description = "ID for the db subnet group"
  value       = aws_db_subnet_group.db_subnet_group.id
}

output "igw_id" {
  description = "ID for the internet gateway"
  value       = aws_internet_gateway.igw.id
}

# output "eip_ids" {
#   description = "ID for the elastic IP"
#   value       = aws_eip.nat_eip.id
# }

# output "ngw_ids" {
#   description = "ID for the NAT gateway"
#   value       = aws_nat_gateway.ngw.id
# }

output "private_rt_id" {
  description = "ID for the private route table"
  value       = aws_route_table.private_rt.id
}

output "subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}
