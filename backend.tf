terraform {
  backend "s3" {
    bucket  = "wordpress-project-tf-state"
    key     = "terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

// This file configures the backend for Terraform state management.
