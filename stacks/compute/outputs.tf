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