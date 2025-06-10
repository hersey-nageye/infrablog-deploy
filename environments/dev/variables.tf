variable "vpc_cidr" {
  type        = string
  description = "Cidr blocks for the VPC"

}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
}

variable "subnet_availability_zones" {
  type        = list(string)
  description = "List of availability zones for all subnets"
}


variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Cidr blocks for the private subnets"
}

variable "bastion_name" {
  type        = string
  description = "Name tag used for identifying the bastion resource in AWS"
}

variable "vault_name" {
  type        = string
  description = "Name tag of vault resource"

}

variable "subnet_group_description" {
  type        = string
  description = "Description of the subnet group for database or application resources"
}

variable "subnet_group_name" {
  type        = string
  description = "The unique name assigned to the subnet group for resource grouping"
}

variable "environment" {
  type        = string
  description = "The environment for which the resources are being created, e.g., dev, staging, prod"
}

variable "project_name" {
  type        = string
  description = "The name of the project for which the resources are being created"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"

}

variable "associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP address with the instance"

}

variable "key_name" {
  type        = string
  description = "Name of the existing key pair to use for SSH access"

}

variable "ipv4_cidr" {
  type        = string
  description = "CIDR block for source IP address"
}

variable "ami_name_filter" {
  type        = string
  description = "Name pattern for the Ubuntu AMI image"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_onwer_id" {
  type        = string
  description = "Owner ID of the Ubuntu AMI"
  default     = "099720109477"
}

variable "wp_name" {
  type        = string
  description = "Name tag used for identifying the Wordpress resource in AWS"

}
