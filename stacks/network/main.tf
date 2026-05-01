module "terraform-vpc" {
  source             = "./modules/vpc-module"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  create_nat_gateway = var.create_nat_gateway
}