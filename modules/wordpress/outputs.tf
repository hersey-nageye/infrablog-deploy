output "wordpress_security_group_id" {
  description = "value of the security group ID for the WordPress instance"
  value       = aws_security_group.wordpress_sg.id
}

output "wordpress_instance_id" {
  description = "ID of the WordPress instance"
  value       = aws_instance.wordpress.id

}
