# VPC RESOURCE VARIABLES

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "bool_dns_hostnames" {
  description = "Boolean value for enabling DNS hostname allocation in VPC"
  type        = bool
  default     = true
}

variable "bool_dns_support" {
  description = "Boolean value for enabling DNS resolution support in VPC"
  type        = bool
  default     = true
}

variable "vpc_name_tag" {
  description = "Name tag for the VPC"
  type        = string
  default     = ""
}

# IGW VARIABLES

variable "igw_name_tag" {
  description = "Name tag for the IGW"
  type        = string
  default     = ""
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