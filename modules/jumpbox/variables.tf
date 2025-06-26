variable "vpc_id" {
  description = "ID of the VPC where the jumpbox will be deployed"
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
  description = "Owner ID of the AMI to use for the jumpbox instance"
  type        = string

}

variable "ami_name_filter" {
  description = "Name filter for the AMI to use for the jumpbox instance"
  type        = string

}

variable "instance_type" {
  description = "Instance type for the jumpbox instance"
  type        = string

}

variable "subnet_id" {
  description = "ID of the subnet where the jumpbox will be deployed"
  type        = string

}
