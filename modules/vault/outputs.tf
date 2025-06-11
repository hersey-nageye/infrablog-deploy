output "sg_id" {
  value = aws_security_group.vault_sg.id
}
output "vault_instance_id" {
  value = aws_instance.vault_server.id
}

output "vault_private_ip" {
  value = aws_instance.vault_server.private_ip

}
