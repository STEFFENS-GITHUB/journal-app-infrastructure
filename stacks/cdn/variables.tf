variable "default_origin_id" {
  type = string
}

variable "apigw_origin_id" {
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

variable "web_acl_name" {
  description = "web acl name for WAF"
  type        = string
}

variable "rate_limit_rule" {
  description = "Name for the rate limiting rule of web acl"
  type        = string
}