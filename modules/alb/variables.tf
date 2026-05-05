variable "vpc_id" {
  description = "VPC ID provided by module call"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "internal" {
    description = "Flag for whether ALB is internal only or not"
    type = bool
    default = false
}

variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

variable "alb_security_group_ids" {
  description = "A list of security group IDs for the ALB"
  type        = list(string)
}