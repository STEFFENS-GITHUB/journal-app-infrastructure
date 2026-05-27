variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

variable "ecs_log_group_name" {
  description = "Log group name for ECS"
  type        = string
}

variable "family_name" {
  description = "Family name for ECS task and container"
  type        = string
}

variable "container_image" {
  description = "Container image name"
  type        = string
}

variable "domain_name" {
  description = "Root domain name for the app"
  type        = string
}