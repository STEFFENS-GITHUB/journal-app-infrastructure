# GENERAL VARS 

variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

# VPC RESOURCE VARIABLES

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Boolean value for enabling DNS hostname allocation in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Boolean value for enabling DNS resolution support in VPC"
  type        = bool
  default     = true
}


# SUBNET VARIABLES

variable "public_subnets" {
  description = "Object for defining public subnets"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    dns_name          = bool
  }))
}

variable "private_subnets" {
  description = "Object for defining private subnets"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    dns_name          = bool
  }))
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = false
}