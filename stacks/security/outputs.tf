output "rds_kms_key_arn" {
  value = module.rds_kms_key.key_arn
}

output "rds_master_user_kms_key_arn" {
  value = module.rds_master_user_kms_key.key_arn
}

output "rds_security_group_ids" {
    value = [aws_security_group.rds_security_group.id]
}

output "alb_security_group_ids" {
    value = [aws_security_group.alb_security_group.id]
}

output "ecs_service_security_group_ids" {
    value = [aws_security_group.ecs_service_security_group.id]
}

output "ecs_task_policy_arn" {
    value = aws_iam_policy.ecs_task_policy.arn
}

output "ecs_execution_policy_arn" {
    value = aws_iam_policy.ecs_execution_policy.arn
}