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
variable "bt_sg_description" {
  type        = string
  description = "Security group description"
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
