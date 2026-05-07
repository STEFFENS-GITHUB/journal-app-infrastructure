output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.target_group.arn
}

output "alb_zone_id" {
  description = "The ARN of the target group"
  value       = aws_lb.load_balancer.zone_id
}

output "alb_dns_name" {
  description = "The ARN of the target group"
  value       = aws_lb.load_balancer.dns_name
}
