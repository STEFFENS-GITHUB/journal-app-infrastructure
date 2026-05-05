# Fill in outputs as needed

output "db_secret_arn" {
  value = aws_db_instance.rds_instance.master_user_secret[0].secret_arn
}

output "endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "db_name" {
  value = aws_db_instance.rds_instance.db_name
}