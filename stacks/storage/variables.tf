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

variable "skip_final_snapshot" {
  description = "Skip creating a final snapshot before deletion"
  type        = bool
}