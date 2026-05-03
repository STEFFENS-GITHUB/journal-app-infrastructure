provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "dev-terraform-state-476140239102"
    key            = "global/backend/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = true
    encrypt        = true
  }
}