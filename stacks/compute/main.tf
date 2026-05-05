module "alb" {
  source                 = "../../modules/alb"
  vpc_id                 = data.terraform_remote_state.network_state.outputs.vpc_id
  public_subnet_ids      = data.terraform_remote_state.network_state.outputs.public_subnet_ids
  private_subnet_ids     = data.terraform_remote_state.network_state.outputs.private_subnet_ids
  env = var.env
  alb_security_group_ids = data.terraform_remote_state.security_state.outputs.alb_security_group_ids
}

module "ecs" {
  source                 = "../../modules/ecs"
  vpc_id                 = data.terraform_remote_state.network_state.outputs.vpc_id
  public_subnet_ids      = data.terraform_remote_state.network_state.outputs.public_subnet_ids
  private_subnet_ids     = data.terraform_remote_state.network_state.outputs.private_subnet_ids
  log_group_name = var.log_group_name
  env = var.env
  ecs_execution_policy_arn = data.terraform_remote_state.security_state.outputs.ecs_execution_policy_arn
  ecs_task_policy_arn = data.terraform_remote_state.security_state.outputs.ecs_task_policy_arn
  family_name = var.family_name
  target_group_arn = module.alb.target_group_arn
  ecs_service_security_group_ids = data.terraform_remote_state.security_state.outputs.ecs_service_security_group_ids
  container_definitions = jsonencode([
      {
        name = var.family_name
        image = var.container_image
        cpu = 512
        memory = 1024
        essential = true
        portMappings = [{ # Modularize at later date
                containerPort = 8000
                hostPort = 8000
                protocol = "tcp"
            }]
        secrets = [
          {
            name = "DB_MASTER_SECRET"
            valueFrom = data.terraform_remote_state.database_state.outputs.db_secret_arn
          }
        ]
        environment = [
          {
            name = "DB_ENDPOINT"
            value = data.terraform_remote_state.database_state.outputs.db_endpoint
          },
          {
            name = "DB_NAME"
            value = data.terraform_remote_state.database_state.outputs.db_name
          }
        ]
        logConfiguration = { # Modularize at later date 
          logDriver="awslogs"
          options = {
            awslogs-group = var.log_group_name
            awslogs-region = "us-east-1"
            awslogs-stream-prefix = "journal-app"
          }
        }
      }
    ])
}



