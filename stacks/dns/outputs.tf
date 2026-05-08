output "acm_certificate_arn" {
    value = aws_acm_certificate.acm_certificate.arn
}

output "dev_hosted_zone_id" {
    value = aws_route53_zone.dev_hosted_zone.zone_id
}