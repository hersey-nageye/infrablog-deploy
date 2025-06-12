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
  description = "ID for the public subnet"
}

variable "ipv4_cidr" {
  type        = string
  description = "CIDR block for source IP address"
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

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"

}
variable "project_name" {
  type        = string
  description = "The name of the project for which the resources are being created"
}

variable "environment" {
  type        = string
  description = "The environment for which the resources are being created, e.g., dev, staging, prod"

}
