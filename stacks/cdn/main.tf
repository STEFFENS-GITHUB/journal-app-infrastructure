data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
    origin {
        domain_name = data.terraform_remote_state.compute_state.outputs.origin_record_fqdn
        origin_id = "${var.origin_id}-${var.env}"

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }
    default_cache_behavior { # ??
        allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods = ["GET", "HEAD", "OPTIONS"]
        target_origin_id = "${var.origin_id}-${var.env}"
        viewer_protocol_policy = "redirect-to-https"
        cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
        origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
    }
    viewer_certificate {
        acm_certificate_arn      = aws_acm_certificate_validation.acm_certificate_validation.certificate_arn
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    enabled = true
    aliases = ["${var.env}.${var.domain_name}"] # Needs to be via variable
}

resource "aws_acm_certificate" "cdn_acm_certificate" {
  domain_name       = "${var.env}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation_record" {
    zone_id = data.terraform_remote_state.dns_state.outputs.dev_hosted_zone_id
    name = tolist(aws_acm_certificate.cdn_acm_certificate.domain_validation_options)[0].resource_record_name
    type = tolist(aws_acm_certificate.cdn_acm_certificate.domain_validation_options)[0].resource_record_type
    ttl = 60
    records = [tolist(aws_acm_certificate.cdn_acm_certificate.domain_validation_options)[0].resource_record_value]
}

resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn = aws_acm_certificate.cdn_acm_certificate.arn

  validation_record_fqdns = [
    aws_route53_record.acm_validation_record.fqdn
  ]
}

resource "aws_route53_record" "cdn_record" {
    zone_id = data.terraform_remote_state.dns_state.outputs.dev_hosted_zone_id
    name = "${var.env}.${var.domain_name}"
    type    = "A"

    alias {
        name    = aws_cloudfront_distribution.cloudfront_distribution.domain_name
        zone_id = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
        evaluate_target_health = false
    }
}