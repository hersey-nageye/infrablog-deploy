output "vault_private_ip" {
  value = aws_instance.vault.private_ip
}

output "vault_sg_id" {
  value = aws_security_group.vault_sg.id

}
