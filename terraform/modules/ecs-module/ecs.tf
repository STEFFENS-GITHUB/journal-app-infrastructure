resource "aws_ecs_cluster" "terraform-ecs-cluster" {
  name = "terraform-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/terraform-ecs-logs"
}

resource "aws_ecs_task_definition" "examplevotingapp-vote-definition" {
  family                   = "examplevotingapp_vote-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions    = file("${path.module}/vote_container_definitions.json")
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "terraform-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "ecs-cloudwatch-logs-policy"
  description = "Allows ECS tasks to write to CloudWatch Logs"

  policy = var.cloudwatch_logs_policy
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_ecs_service" "ecs-service-voting-app" {
  name            = "terraform-ecs-service-voting-app"
  cluster         = aws_ecs_cluster.terraform-ecs-cluster.id
  task_definition = aws_ecs_task_definition.examplevotingapp-vote-definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs-service-sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_vote_target_group.arn
    container_name   = "vote"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.http_listener, aws_security_group.ecs-service-sg]#, aws_lb_listener.https_listener]
}

resource "aws_security_group" "ecs-service-sg" {
  name   = "ecs-service-voting-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-lb-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# load balancer?

