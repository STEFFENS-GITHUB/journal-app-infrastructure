module "rds_instance" {
    source             = "../../modules/rds"
    rds_key_arn = data.terraform_remote_state.security_state.outputs.rds_kms_key_arn
    rds_master_user_key_arn = data.terraform_remote_state.security_state.outputs.rds_master_user_kms_key_arn
    subnet_ids = data.terraform_remote_state.network_state.outputs.private_subnet_ids
    db_security_group_ids = data.terraform_remote_state.security_state.outputs.rds_security_group_ids
    engine = var.engine
    engine_version = var.engine_version
    master_username = var.master_username
    db_name = var.db_name
    skip_final_snapshot = var.skip_final_snapshot
    env = var.env
}