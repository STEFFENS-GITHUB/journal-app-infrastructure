output "rds_kms_key_arn" {
  value = module.rds_kms_key.key_arn
}

output "rds_master_user_kms_key_arn" {
  value = module.rds_master_user_kms_key.key_arn
}

output "rds_security_group_ids" {
    value = [aws_security_group.rds_security_group.id]
}