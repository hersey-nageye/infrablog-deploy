variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to the security group."
  type        = map(string)
  default     = {}
}
variable "project_name" {
  description = "The name of the project for tagging purposes."
  type        = string
}

variable "ami_owner_id" {
  description = "The AWS account ID of the AMI owner."
  type        = string
}

variable "ami_name_filter" {
  description = "The name filter for the AMI to be used."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the vault server."
  type        = string

}

variable "subnet_id" {
  description = "The ID of the subnet where the vault server will be launched."
  type        = string

}
