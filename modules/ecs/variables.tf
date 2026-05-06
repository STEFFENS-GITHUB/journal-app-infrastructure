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

variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

variable "log_group_name" {
  description = "Log group name for ECS"
  type        = string
}

variable "ecs_execution_policy_arn" {
  description = "ECS execution role permissions policy ARN"
  type        = string
}

variable "ecs_task_policy_arn" {
  description = "ECS task role permissions policy ARN"
  type        = string
}

variable "family_name" {
  description = "Family name for app being deployed by ECS"
  type        = string
}

variable "task_definition_memory" {
  description = "task definition memory in bits/units (ie 512)"
  type        = string
  default     = "1024"
}

variable "task_definition_cpu" {
  description = "task definition CPU in bits/units (ie 512)"
  type        = string
  default     = "512"
}

variable "container_definitions" {
  description = "A JSON string of the container definitions for ECS to run"
  type        = string
}

variable "ecs_service_security_group_ids" {
  description = "A list of security group ids for ECS service"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the target group to register the ECS service with"
  type        = string
}