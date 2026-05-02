resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = "${var.env}-vpc"
    Environment = var.env
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw-${var.env}"
    Environment = var.env
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.create_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  availability_mode = "regional"
    tags = {
      Name = "natgw-${var.env}"
      Environment = var.env
  }
}