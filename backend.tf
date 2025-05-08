terraform {
  backend "s3" {
    bucket = "wordpress-project-tf-state"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

