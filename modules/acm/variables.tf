variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

variable "domain_name" {
  description = "Root domain name for the app"
  type        = string
}

variable "domain_name_prefix" {
  description = "Domain name prefix. (Ensure dot at end if not using default)"
  type        = string
  default = ""
}

variable "hosted_zone_id" {
  description = "dev hosted zone id"
  type        = string
}