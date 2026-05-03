output "key_arn" {
  description = "The KMS key arn"
  value       = aws_kms_key.kms_key.arn
}

output "key_alias" {
  description = "The KMS key alias"
  value       = aws_kms_alias.key_alias.name
}