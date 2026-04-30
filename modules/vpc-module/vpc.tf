resource "aws_vpc" "terraform-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.bool_dns_hostnames
  enable_dns_support   = var.bool_dns_support
  tags = {
    Name = var.vpc_name_tag
  }
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = var.igw_name_tag
  }
  depends_on = [
    aws_vpc.terraform-vpc
  ]
}

resource "aws_subnet" "public_subnets" {
  for_each = { for i, subnet in var.public_subnets : i => subnet }

  cidr_block                                  = each.value.cidr_block
  availability_zone                           = each.value.availability_zone
  enable_resource_name_dns_a_record_on_launch = each.value.dns_name

  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.terraform-vpc.id

  tags = {
    Tier = "public"
  }

  depends_on = [
    aws_vpc.terraform-vpc
  ]
}

resource "aws_subnet" "private_subnets" {
  for_each = { for i, subnet in var.private_subnets : i => subnet }

  cidr_block                                  = each.value.cidr_block
  availability_zone                           = each.value.availability_zone
  enable_resource_name_dns_a_record_on_launch = each.value.dns_name

  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Tier = "private"
  }

  depends_on = [
    aws_vpc.terraform-vpc
  ]
}

resource "aws_eip" "ng_eip" {
  count  = var.create_nat_gateway ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gateway" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.ng_eip[0].id
  subnet_id     = element(values(aws_subnet.public_subnets)[*].id, 0)
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  count                  = var.create_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat-gateway[0].id
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}