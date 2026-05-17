resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = "${var.domain_name_prefix}${var.env}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_route53_record" "acm_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id         = var.hosted_zone_id
  ttl             = 60
  name            = each.value.name
  type            = each.value.type
  allow_overwrite = true
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn = aws_acm_certificate.acm_certificate.arn

  validation_record_fqdns = [for record in aws_route53_record.acm_validation_record : record.fqdn]
}