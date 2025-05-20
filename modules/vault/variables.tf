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
