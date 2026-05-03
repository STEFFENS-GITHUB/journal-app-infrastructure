output "key_id" {
  description = "The KMS key id"
  value       = aws_kms_key.kms_key.key_id
}

output "key_alias" {
  description = "The KMS key alias"
  value       = aws_kms_alias.key_alias.name
}