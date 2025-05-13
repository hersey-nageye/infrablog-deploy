variable "sg_name" {
  type        = string
  description = "Name for the security group"
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
}

variable "name" {
  type        = string
  description = "Name of resource tag"
}

variable "key_name" {
  type        = string
  description = "SSH key name"
}

variable "public_key" {
  type        = string
  description = "Link to the public key file"
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
  description = "Sg id for the bastion server security group"
}
