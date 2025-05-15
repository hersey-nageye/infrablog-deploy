variable "vpc_cidrs" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnet_availability_zones" {
  type        = list(string)
  description = "Subnet availability zones"
}

variable "subnet_group_description" {
  type        = string
  description = "Name of the subnet group"
}

variable "public_subnet_cidrs" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets"
}

variable "name_tag" {
  type        = string
  description = "Name tag for the resource"
}

variable "key_name" {
  type        = string
  description = "SSH key name"
}

variable "public_key_path" {
  type        = string
  description = "Path to the public key file used for SSH access"
  default     = "~/Projects/.ssh/terraform-key.pub"
}

variable "ami_name_filter" {
  type        = string
  description = "Name pattern for the Ubuntu AMI image"
}

variable "ami_onwer_id" {
  type        = string
  description = "Owner ID of the Ubuntu AMI"
}

variable "sg_name" {
  type        = string
  description = "Name of the Vault security group"
}

variable "wp_sg_description" {
  type        = string
  description = "Description of the wordpress security group"
}

variable "rds_sg_description" {
  type        = string
  description = "Description of the RDS security group"
}

variable "subnet_group_name" {
  type        = string
  description = "Name of the RDS subnet group"
}

variable "db_name" {
  type        = string
  description = "Database name"
}
