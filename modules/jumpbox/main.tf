resource "aws_security_group" "jumobox_sg" {
  name        = "vault-sg"
  description = "Security group for Vault instance"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "jumpbox_ssh" {
  security_group_id = aws_security_group.jumobox_sg.id
  cidr_ipv4         = "0.0.0.0/0" # Change this to your IP address later
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox-ssh-rule"
  })

}

# Data block to read existing key pair
data "aws_key_pair" "existing_key" {
  key_name = "terraform"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-key-pair"
    }
  )
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner_id]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "jumpbox" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids      = [aws_security_group.jumobox_sg.id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/../../scripts/create-wordpress-db.sql")


  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox"
  })
}

