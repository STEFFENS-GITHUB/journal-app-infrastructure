resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-${var.env}"
    tags = {
      Environment = var.env
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.family_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # May eventually add EC2 compatability, but fargate only for now
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions    = var.container_definitions
  tags = {
      Environment = var.env
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service-${var.env}"
  cluster         = aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1 # Review auto scaling for ECS later
  launch_type     = "FARGATE" # May eventually add EC2 compatability, but fargate only for now

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = var.ecs_service_security_group_ids
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.family_name
    container_port   = 8000 # Modularize later
  }
  tags = {
     Environment = var.env
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = var.log_group_name
}