provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "terraform-remote-backend-2024"
    key            = "global/backend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-backend-state-locking"
    encrypt        = true
  }
}