output "db_secret_arn" {
  value = module.rds_instance.db_secret_arn
}

output "db_endpoint" {
  value = module.rds_instance.endpoint
}

output "db_name" {
  value = module.rds_instance.db_name
}