# Must take credentials and connection data as vars / outputs
# Instance sizing / power as input with defaults maybe
# port

# OPTIONAL VARS (default defined) ^^^^^

variable "storage_type" {
  description = "Database storage type (ie. gp2)"
  type        = string
  default     = "gp3"
}

variable "allocated_storage" {
  description = "Number of gigs of storage in DB"
  type        = number
  default     = 20
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible or not"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip creating a final snapshot before deletion"
  type        = bool
  default     = false
}

# MANDATORY VARS

variable "env" {
  description = "Environment (dev, prod, staging)"
  type        = string
}

variable "engine" {
  description = "Database engine (ie. MySQL)"
  type        = string
}

variable "engine_version" {
  description = "Database engine version (ie. 8.0)"
  type        = string
}

variable "master_username" {
  description = "Master username to access the database"
  type        = string
}

variable "db_name" {
  description = "Name of the initial database on the rds instance"
  type        = string
}

variable "rds_master_user_key_arn" {
  description = "ARN of the KMS Master User Key"
  type        = string
}

variable "rds_key_arn" {
  description = "ARN of the KMS Master User Key"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_security_group_ids" {
  description = "A list of security group ids to be applied to the database"
  type        = list(string)
}