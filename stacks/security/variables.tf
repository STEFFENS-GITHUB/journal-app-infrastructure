variable "rds_kms_deletion_window_in_days" {
  description = "KMS key deletion window specified in days"
  type        = number
}

variable "rds_kms_enable_key_rotation" {
  description = "KMS key bool flag to enable key rotation"
  type        = bool
}

variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}