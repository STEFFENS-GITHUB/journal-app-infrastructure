data "aws_route53_zone" "root_hosted_zone" {
  provider     = aws.root
  name         = "steffenaws.com."
  private_zone = false
}

resource "aws_route53_zone" "dev_hosted_zone" {
  name = "dev.steffenaws.com"
}

resource "aws_route53_record" "delegation_record" {
  provider = aws.root
  zone_id  = data.aws_route53_zone.root_hosted_zone.zone_id
  name     = "dev.steffenaws.com"
  type     = "NS"
  ttl      = 180

  records = aws_route53_zone.dev_hosted_zone.name_servers
}

resource "aws_route53_record" "app_record" {
  zone_id = aws_route53_zone.dev_hosted_zone.zone_id
  name    = "dev.steffenaws.com"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.compute_state.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.compute_state.outputs.alb_zone_id
    evaluate_target_health = true
  }
}