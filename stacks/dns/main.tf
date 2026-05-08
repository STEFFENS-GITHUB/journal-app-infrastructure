data "aws_route53_zone" "root_hosted_zone" {
  provider     = aws.root
  name         = "steffenaws.com."
  private_zone = false
}

resource "aws_route53_zone" "dev_hosted_zone" {
  name = "${var.env}.${var.domain_name}"
}

resource "aws_route53_record" "delegation_record" {
  provider = aws.root
  zone_id  = data.aws_route53_zone.root_hosted_zone.zone_id
  name     = "${var.env}.${var.domain_name}"
  type     = "NS"
  ttl      = 180

  records = aws_route53_zone.dev_hosted_zone.name_servers
}

resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = "${var.env}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation_record" {
    zone_id = aws_route53_zone.dev_hosted_zone.id
    name = tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_name
    type = tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_type
    ttl = 60
    records = [tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_value]
}

resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn = aws_acm_certificate.acm_certificate.arn

  validation_record_fqdns = [
    aws_route53_record.acm_validation_record.fqdn
  ]
}