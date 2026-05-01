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

variable "cloudwatch_logs_policy" {
  description = "JSON document for cloudwatch logs policy"
  type        = string
}