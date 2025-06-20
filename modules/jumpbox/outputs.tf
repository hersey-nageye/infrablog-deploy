output "jumpbox_sg_id" {
  value = aws_security_group.jumobox_sg.id
}

output "jumpbox_instance_id" {
  value = aws_instance.jumpbox.id

}
