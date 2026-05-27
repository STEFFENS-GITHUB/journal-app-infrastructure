output "alb_zone_id" {
  description = "The ARN of the target group"
  value       = module.alb.alb_zone_id
}

output "alb_dns_name" {
  description = "The ARN of the target group"
  value       = module.alb.alb_dns_name
}

output "origin_record_fqdn" {
  description = "FQDN of the origin record"
  value       = aws_route53_record.origin_record.fqdn
}

output "api_gateway_invoke_domain" {
  value = "${aws_api_gateway_rest_api.api_gateway.id}.execute-api.us-east-1.amazonaws.com"
}