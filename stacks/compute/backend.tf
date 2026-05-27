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
    key          = "backend/compute/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
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

data "terraform_remote_state" "security_state" {
  backend = "s3"

  config = {
    bucket = "dev-terraform-state-476140239102"
    key    = "backend/security/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "storage_state" {
  backend = "s3"

  config = {
    bucket = "dev-terraform-state-476140239102"
    key    = "backend/storage/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "dns_state" {
  backend = "s3"

  config = {
    bucket = "dev-terraform-state-476140239102"
    key    = "backend/dns/terraform.tfstate"
    region = "us-east-1"
  }
}