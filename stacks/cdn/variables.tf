variable "origin_id" {
    type = string
}

variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

variable "domain_name" {
  description = "Root domain name for the app"
  type        = string
}