resource "aws_subnet" "public_subnets" {
  for_each = { for i, subnet in var.public_subnets : i => subnet }

  cidr_block                                  = each.value.cidr_block
  availability_zone                           = each.value.availability_zone
  enable_resource_name_dns_a_record_on_launch = each.value.dns_name

  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    Tier = "public"
    Environment = var.env
    Name = "${var.env}-public-subnet-${each.key}"
  }

  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "private_subnets" {
  for_each = { for i, subnet in var.private_subnets : i => subnet }

  cidr_block                                  = each.value.cidr_block
  availability_zone                           = each.value.availability_zone
  enable_resource_name_dns_a_record_on_launch = each.value.dns_name

  vpc_id = aws_vpc.vpc.id

  tags = {
    Tier = "private"
    Environment = var.env
    Name = "${var.env}-private-subnet-${each.key}"
  }

  depends_on = [
    aws_vpc.vpc
  ]
}