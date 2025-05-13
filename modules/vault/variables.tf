variable "sg_name" {
  type        = string
  description = "Name of the security group"
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
}

variable "name_tag" {
  type        = string
  description = "Name tag for the resource"
}

variable "subnet_id" {
  type        = string
  description = "ID for the subnet"
}

variable "key_name" {
  type        = string
  description = "SSH key name"
}

variable "public_key" {
  type        = string
  description = "File link to the public key"
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
