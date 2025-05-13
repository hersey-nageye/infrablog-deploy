# terraform.tfvars

name_tag = "wordpress-project"

# VPC
vpc_cidrs                 = "value"
subnet_availability_zones = ["eu-west-1", "eu-west-2"]
subnet_group_description  = "rds-subnet-group"
public_subnet_cidrs       = "10.0.1.0/24"
private_subnet_cidrs      = ["10.0.2.0/24", "10.0.3.0/24"]

# SSH
key_name        = "terraform"
public_key_path = "~/Projects/.ssh/terraform-key.pub"

# EC2 AMI
ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
ami_onwer_id    = "099720109477"

