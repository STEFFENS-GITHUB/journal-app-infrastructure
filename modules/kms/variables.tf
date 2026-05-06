# OPTIONAL VARS (default defined)

variable "deletion_window_in_days" {
  description = "KMS key deletion window specified in days"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "KMS key bool flag to enable key rotation"
  type        = bool
  default     = false
}

# MANDATORY VARS

variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

variable "key_name" {
  description = "Key name used in key tag Name and key alias name"
  type        = string
}

variable "key_policy" {
  type = string
}