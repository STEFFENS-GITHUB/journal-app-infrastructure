module "kms" {
    source             = "../../modules/kms"
    deletion_window_in_days = var.rds_kms_deletion_window_in_days
    enable_key_rotation = var.rds_kms_enable_key_rotation
    env = var.env
    key_name = var.rds_kms_key_name
    key_policy=data.aws_iam_policy_document.rds_kms_policy.json
}