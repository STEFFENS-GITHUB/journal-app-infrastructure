output "db_secret_arn" {
  value = module.rds_instance.db_secret_arn
}

output "db_endpoint" {
  value = module.rds_instance.endpoint
}

output "db_name" {
  value = module.rds_instance.db_name
}

output "display_get_bucket_id" {
  value = aws_s3_bucket.display_get_bucket.id
}

output "display_get_bucket_arn" {
  value = aws_s3_bucket.display_get_bucket.arn
}