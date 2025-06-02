output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom-vpc.id
}

output "public_subnet_id" {
  description = "The IDs for the public subnet"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  description = "The IDs for the private subnets"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "aws_db_subnet_group_id" {
  description = "ID for the db subnet group"
  value       = aws_db_subnet_group.db_subnet_group.id
}

output "igw_id" {
  description = "ID for the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "eip_id" {
  description = "ID for the elastic IP"
  value       = aws_eip.nat_eip[0].id
}

output "ngw_id" {
  description = "ID for the NAT gateway"
  value       = aws_nat_gateway.ngw[0].id
}

output "private_rt_id" {
  description = "ID for the private route table"
  value       = aws_route_table.private_rt
}

output "subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}

output "public_rt_id" {
  description = "ID for the public route table"
  value       = aws_route_table.public_rt.id
}
output "public_rta_ids" {
  description = "IDs for the public route table associations"
  value       = [for rta in aws_route_table_association.public_rta : rta.id]
}
output "private_rta_ids" {
  description = "IDs for the private route table associations"
  value       = [for rta in aws_route_table_association.private_rta : rta.id]
}
