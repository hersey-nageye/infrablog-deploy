variable "sg_name" {
  type        = string
  description = "Name of the security group"
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
}

variable "name" {
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
