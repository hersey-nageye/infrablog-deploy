resource "null_resource" "fetch_vault_token" {
  depends_on = [module.vault]

  provisioner "local-exec" {
    command = "ssh -i ${var.private_key_path} ubuntu@${module.vault.vault_private_ip} 'cat /root/wordpress-token.txt' > wordpress-token.txt"

  }

  triggers = {
    always_run = timestamp()
  }
}
