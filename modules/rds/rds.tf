resource "aws_db_instance" "rds_instance" {
  engine                        = var.engine
  engine_version                = var.engine_version
  instance_class                = "db.t3.micro"
  manage_master_user_password   = true # May add support to disable this in future
  master_user_secret_kms_key_id = var.rds_master_user_key_arn
  username                      = var.master_username
  kms_key_id                    = var.rds_key_arn
  storage_encrypted             = true # May add support to disable this in future
  identifier                    = "rds-${var.env}"
  storage_type                  = var.storage_type
  allocated_storage             = var.allocated_storage
  skip_final_snapshot           = var.skip_final_snapshot
  db_subnet_group_name          = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible           = var.publicly_accessible
  vpc_security_group_ids        = var.db_security_group_ids
  db_name                       = var.db_name
  tags = {
    Name        = "rds-${var.env}"
    Environment = var.env
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-${var.env}"
  subnet_ids = var.subnet_ids
  tags = {
    Name        = "rds-subnet-group-${var.env}"
    Environment = var.env
  }
}