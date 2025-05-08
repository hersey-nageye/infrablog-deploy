output "sg_id" {
  value = aws_security_group.vault_sg.id
}

output "key_pair_id" {
  value = aws_key_pair.ssh_access_key.id
}
