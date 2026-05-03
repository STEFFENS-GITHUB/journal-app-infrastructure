# Fill in outputs as needed

output "db_secret_arn" {
  value = aws_db_instance.rds_instance.master_user_secret[0].secret_arn
}