data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_wafv2_web_acl" "cdn_web_acl" {
  name  = var.web_acl_name
  scope = "CLOUDFRONT"

    lifecycle {
    ignore_changes = [rule]
    }

  tags = {
    Environment = var.env
  }

    custom_response_body {
        key = "waf_block_json"
        content = "Rate limit exceeded by WAF."
        content_type = "TEXT_PLAIN"
    }
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.web_acl_name
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_rule" "rate_limit_rule" {
    name = var.rate_limit_rule
    priority = 1
    web_acl_arn = aws_wafv2_web_acl.cdn_web_acl.arn

    action { 
        block {
            custom_response {
                response_code = 429
                custom_response_body_key = "waf_block_json"
            }
        } 
    }

    statement {
        rate_based_statement {
            limit = 500
            aggregate_key_type = "IP"
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = var.rate_limit_rule
        sampled_requests_enabled   = true
  }
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  tags = {
    Environment = var.env
  }

  origin {
    domain_name = data.terraform_remote_state.compute_state.outputs.origin_record_fqdn
    origin_id   = "${var.default_origin_id}-${var.env}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = "notmadeyet.steffenaws.com" #data.terraform_remote_state.compute_state.outputs.origin_record_fqdn
    origin_id   = "${var.apigw_origin_id}-${var.env}"
    origin_path = "/${var.env}"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = "${var.default_origin_id}-${var.env}"
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = "${var.apigw_origin_id}-${var.env}"
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
    path_pattern             = "/api/lambda/*"
  }

  viewer_certificate {
    acm_certificate_arn      = module.cdn_acm_certificate.acm_certificate_validation_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_100"
  web_acl_id = aws_wafv2_web_acl.cdn_web_acl.arn
  aliases = ["${var.env}.${var.domain_name}"] # Needs to be via variable
}

module "cdn_acm_certificate" {
  source         = "../../modules/acm"
  env            = var.env
  domain_name    = var.domain_name
  hosted_zone_id = data.terraform_remote_state.dns_state.outputs.dev_hosted_zone_id
}

resource "aws_route53_record" "cdn_record" {
  zone_id = data.terraform_remote_state.dns_state.outputs.dev_hosted_zone_id
  name    = "${var.env}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}