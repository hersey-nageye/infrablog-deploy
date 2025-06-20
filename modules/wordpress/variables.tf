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

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string

}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string

}

variable "vault_private_ip" {
  description = "Private IP address for the Vault instance"
  type        = string

}

variable "db_host" {
  description = "Hostname for the RDS database"
  type        = string

}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string

}
