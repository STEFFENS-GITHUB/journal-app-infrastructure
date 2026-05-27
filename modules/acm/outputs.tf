output "acm_certificate_validation_arn" {
    value = aws_acm_certificate_validation.acm_certificate_validation.certificate_arn
}

output "fqdn" {
    value = "${var.domain_name_prefix}${var.env}.${var.domain_name}"
}