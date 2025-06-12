variable "name" {
  type        = string
  description = "Name tag for resource"
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
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

variable "subnet_id" {
  type        = string
  description = "ID for the subnet"
}

variable "sg_id" {
  type        = string
  description = "Security group ID for the bastion server security group"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"

}

variable "environment" {
  type        = string
  description = "Environment for the resources (e.g., dev, prod)"
}

variable "project_name" {
  type        = string
  description = "Project name for the resources"

}

variable "ipv4_cidr" {
  type        = string
  description = "IPv4 CIDR for my IP address"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"

}

variable "vault_private_ip" {
  type        = string
  description = "Private IP address for the Vault server"

}
