variable "name" {
  type        = string
  description = "Name tag of resource"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
}

variable "subnet_id" {
  type        = string
  description = "ID for the subnet"
}

variable "ami_name_filter" {
  type        = string
  description = "Name pattern for the Ubuntu AMI image"
}

variable "ami_onwer_id" {
  type        = string
  description = "Owner ID of the Ubuntu AMI"
}

variable "sg_id" {
  type        = string
  description = "SG ID for the Bastion server"
}

variable "ipv4_cidr" {
  type        = string
  description = "CIDR block for source IP address"
}

variable "project_name" {
  type        = string
  description = "The name of the project for which the resources are being created"

}

variable "environment" {
  type        = string
  description = "The environment for which the resources are being created, e.g., dev, staging, prod"

}
variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"

}

variable "key_name" {
  type        = string
  description = "Name of the existing key pair to use for SSH access"
}

variable "wordpress_sg_id" {
  type        = string
  description = "Security group ID for the Wordpress application"

}
