variable "name" {
  type        = string
  description = "Name tag for resource"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "wp_sg_description" {
  type        = string
  description = "Description of the wordpress security group"
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
