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

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username of the database"
  type        = string
}

variable "db_password" {
  description = "Password of the database"
  type        = string
}

variable "wp_admin_user" {
  description = "Admin user"
  type        = string
}

variable "wp_admin_password" {
  description = "Admin password"
  type        = string
}

variable "wp_admin_email" {
  description = "Admin email"
  type        = string
}

variable "wp_vault_password" {
  description = "Password"
  type        = string
}

variable "vault_private_ip" {
  description = "Private IP of vault instance"
  type        = string
}
