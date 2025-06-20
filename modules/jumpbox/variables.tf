variable "vpc_id" {
  description = "CIDR block for the VPC"
  type        = string

}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)

}

variable "project_name" {
  description = "Name of the project, used for tagging resources"
  type        = string

}

variable "ami_owner_id" {
  description = "Owner ID for the AMI"
  type        = string

}

variable "ami_name_filter" {
  description = "Name filter for the AMI"
  type        = string

}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string

}

variable "subnet_id" {
  description = "Value of the subnet ID where the instance will be launched"
  type        = string

}
