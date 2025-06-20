output "wordpress_sg_id" {
  description = "Security group ID for the WordPress instance"
  value       = aws_security_group.wordpress_sg.id
}

output "wordpress_instance_id" {
  description = "Instance ID of the WordPress application"
  value       = aws_instance.wordpress.id

}
