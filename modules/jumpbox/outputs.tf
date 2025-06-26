output "jumpbox_security_group_id" {
  description = "ID of the security group for the jumpbox instance"
  value       = aws_security_group.jumpbox_sg.id

}

output "jumpbox_instance_id" {
  description = "ID of the jumpbox instance"
  value       = aws_instance.jumpbox.id

}
