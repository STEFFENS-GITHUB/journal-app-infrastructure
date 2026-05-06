resource "aws_security_group" "rds_security_group" {
  name   = "rds-sg-${var.env}"
  vpc_id = data.terraform_remote_state.network_state.outputs.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace this with ECS SG later, I believe
  }
}

resource "aws_security_group" "alb_security_group" {
  name   = "alb-sg-${var.env}"
  vpc_id = data.terraform_remote_state.network_state.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # Verify if this is necessary. Does it auto create this egress, or no?
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_service_security_group" {
  name   = "ecs-sg-${var.env}"
  vpc_id = data.terraform_remote_state.network_state.outputs.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }
  egress { # Verify if this is necessary. Does it auto create this egress, or no?
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}