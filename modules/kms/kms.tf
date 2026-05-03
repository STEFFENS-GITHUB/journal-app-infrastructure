resource "aws_kms_key" "kms_key" {
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = var.key_policy
  tags = {
    Name        = "${var.key_name}-${var.env}"
    Environment = var.env
  }
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.key_name}-${var.env}"
  target_key_id = aws_kms_key.kms_key.key_id
}