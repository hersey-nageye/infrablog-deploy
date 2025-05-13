output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "wordpress_id" {
  value = aws_instance.wordpress_server.id
}
