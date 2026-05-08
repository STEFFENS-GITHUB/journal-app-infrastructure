provider "aws" {
  region = "us-east-1"
  profile = "dev"
}

provider "aws" {
  alias = "root"
  region = "us-east-1"
  profile = "root"
}

terraform {
  backend "s3" {
    bucket         = "dev-terraform-state-476140239102"
    key            = "backend/dns/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = true
    encrypt        = true
  }
}

data "terraform_remote_state" "compute_state" {
  backend = "s3"

  config = {
    bucket = "dev-terraform-state-476140239102"
    key    = "backend/compute/terraform.tfstate"
    region = "us-east-1"
  }
}