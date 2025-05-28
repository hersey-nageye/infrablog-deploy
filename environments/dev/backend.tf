terraform {
  backend "s3" {
    bucket         = "wordpress-project-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

// This file configures the backend for Terraform state management.
