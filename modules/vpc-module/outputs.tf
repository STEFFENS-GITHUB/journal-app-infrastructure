output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.terraform-vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for i in aws_subnet.public_subnets : i.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for i in aws_subnet.private_subnets : i.id]
}