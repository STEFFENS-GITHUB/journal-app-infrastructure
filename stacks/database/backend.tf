provider "aws" {
  region  = "us-east-1"
  profile = "dev"
}

provider "aws" {
  alias   = "root"
  region  = "us-east-1"
  profile = "root"
}

terraform {
  backend "s3" {
    bucket       = "dev-terraform-state-476140239102"
    key          = "backend/database/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
    profile = "dev"
  }
}

data "terraform_remote_state" "security_state" {
  backend = "s3"

  config = {
    bucket = "dev-terraform-state-476140239102"
    key    = "backend/security/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network_state" {
  backend = "s3"

  config = {
    bucket = "dev-terraform-state-476140239102"
    key    = "backend/network/terraform.tfstate"
    region = "us-east-1"
  }
}