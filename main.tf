module "terraform-vpc" {
  source             = "./modules/vpc-module"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  create_nat_gateway = var.create_nat_gateway
}

module "terraform-ecs" {
  source                 = "./modules/ecs-module"
  cloudwatch_logs_policy = var.cloudwatch_logs_policy
  vpc_id                 = module.terraform-vpc.vpc_id
  public_subnet_ids      = module.terraform-vpc.public_subnet_ids
  private_subnet_ids     = module.terraform-vpc.private_subnet_ids
  depends_on = [
    module.terraform-vpc
  ]
}