data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
    origin {
        domain_name = data.terraform_remote_state.compute_state.outputs.origin_record_fqdn
        origin_id = "${var.default_origin_id}-${var.env}"

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }

    origin {
        domain_name = "notmadeyet.steffenaws.com" #data.terraform_remote_state.compute_state.outputs.origin_record_fqdn
        origin_id = "${var.apigw_origin_id}-${var.env}"
        origin_path = "/${var.env}"
        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods = ["GET", "HEAD", "OPTIONS"]
        target_origin_id = "${var.default_origin_id}-${var.env}"
        viewer_protocol_policy = "redirect-to-https"
        cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
        origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
    }

    ordered_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods = ["GET", "HEAD", "OPTIONS"]
        target_origin_id = "${var.apigw_origin_id}-${var.env}"
        viewer_protocol_policy = "redirect-to-https"
        cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
        origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
        path_pattern = "/api/lambda/*"
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
    is_ipv6_enabled = true
    http_version = "http2and3"
    price_class = "PriceClass_100"
    # web acl
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
    for_each = {
        for dvo in aws_acm_certificate.cdn_acm_certificate.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            type   = dvo.resource_record_type
            record = dvo.resource_record_value
        }
    }

    zone_id = data.terraform_remote_state.dns_state.outputs.dev_hosted_zone_id
    ttl = 60
    name = each.value.name
    type = each.value.type
    allow_overwrite = true
    records = [each.value.record]
}

resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn = aws_acm_certificate.cdn_acm_certificate.arn

  validation_record_fqdns = [for record in aws_route53_record.acm_validation_record : record.fqdn]
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