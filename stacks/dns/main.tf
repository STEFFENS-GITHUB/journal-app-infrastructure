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