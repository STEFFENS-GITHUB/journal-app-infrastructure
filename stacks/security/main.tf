module "rds_kms_key" {
    source             = "../../modules/kms"
    deletion_window_in_days = var.rds_kms_deletion_window_in_days
    enable_key_rotation = var.rds_kms_enable_key_rotation
    env = var.env
    key_name = "rds-key"
    key_policy=data.aws_iam_policy_document.rds_kms_policy.json
}

module "rds_master_user_kms_key" {
    source             = "../../modules/kms"
    deletion_window_in_days = var.rds_kms_deletion_window_in_days
    enable_key_rotation = var.rds_kms_enable_key_rotation
    env = var.env
    key_name = "rds-master-user-key"
    key_policy=data.aws_iam_policy_document.rds_master_user_kms_policy.json
}