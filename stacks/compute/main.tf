module "alb" {
  source                 = "../../modules/alb"
  vpc_id                 = data.terraform_remote_state.network_state.outputs.vpc_id
  public_subnet_ids      = data.terraform_remote_state.network_state.outputs.public_subnet_ids
  private_subnet_ids     = data.terraform_remote_state.network_state.outputs.private_subnet_ids
  env                    = var.env
  alb_security_group_ids = data.terraform_remote_state.security_state.outputs.alb_security_group_ids
  certificate_arn = module.origin_acm_certificate.acm_certificate_validation_arn
}

module "ecs" {
  source                         = "../../modules/ecs"
  vpc_id                         = data.terraform_remote_state.network_state.outputs.vpc_id
  public_subnet_ids              = data.terraform_remote_state.network_state.outputs.public_subnet_ids
  private_subnet_ids             = data.terraform_remote_state.network_state.outputs.private_subnet_ids
  log_group_name                 = var.ecs_log_group_name
  env                            = var.env
  ecs_execution_policy_arn       = data.terraform_remote_state.security_state.outputs.ecs_execution_policy_arn
  ecs_task_policy_arn            = data.terraform_remote_state.security_state.outputs.ecs_task_policy_arn
  family_name                    = var.family_name
  target_group_arn               = module.alb.target_group_arn
  ecs_service_security_group_ids = data.terraform_remote_state.security_state.outputs.ecs_service_security_group_ids
  container_definitions = jsonencode([
    {
      name      = var.family_name
      image     = var.container_image
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{ # Modularize at later date
        containerPort = 8000
        hostPort      = 8000
        protocol      = "tcp"
      }]
      secrets = [
        {
          name      = "DB_MASTER_SECRET"
          valueFrom = data.terraform_remote_state.storage_state.outputs.db_secret_arn
        }
      ]
      environment = [
        {
          name  = "DB_ENDPOINT"
          value = data.terraform_remote_state.storage_state.outputs.db_endpoint
        },
        {
          name  = "DB_NAME"
          value = data.terraform_remote_state.storage_state.outputs.db_name
        }
      ]
      logConfiguration = { # Modularize at later date 
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.ecs_log_group_name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "journal-app"
        }
      }
    }
  ])
}

module "origin_acm_certificate" {
    source                 = "../../modules/acm"
    env = var.env
    domain_name = var.domain_name
    domain_name_prefix = "origin."
    hosted_zone_id = data.terraform_remote_state.bootstrap_state.outputs.dev_hosted_zone_id
}

resource "aws_route53_record" "origin_record" {
  zone_id = data.terraform_remote_state.bootstrap_state.outputs.dev_hosted_zone_id
  name = module.origin_acm_certificate.fqdn
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_object" "lambda_placeholder" {
  bucket = data.terraform_remote_state.storage_state.outputs.display_get_bucket_id
  key    = "latest.zip"
  source = "${path.module}/placeholder.zip"

  lifecycle {
    ignore_changes = all  # Lambda repo owns this object after initial creation
  }
}

# Figure out alias + versions later
resource "aws_lambda_function" "display_get_lambda" {
  function_name = "display-get-lambda"
  role = aws_iam_role.display_get_lambda_execution_role.arn
  handler = "main.lambda_handler"
  publish = true
  runtime = "python3.9"
  s3_bucket = data.terraform_remote_state.storage_state.outputs.display_get_bucket_id
  s3_key = "latest.zip"
  depends_on = [aws_s3_object.lambda_placeholder]
  lifecycle {
    ignore_changes = [layers]
  }
  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_alias" "prod" {
  name             = "prod"
  function_name    = aws_lambda_function.display_get_lambda.function_name
  function_version = "1"

  lifecycle {
    ignore_changes = [function_version]
  }
}

resource "aws_lambda_permission" "display_get_allow_apigw" {
  statement_id  = "AllowAPIGatewayInvokeDisplayGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.display_get_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_rest_api" "api_gateway"{
  name = "api-gateway-${var.env}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part = "api"
}

resource "aws_api_gateway_resource" "display" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id = aws_api_gateway_resource.api.id
  path_part = "display"
}

resource "aws_api_gateway_method" "display_get" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.display.id
  http_method = "GET"
  authorization = "NONE" # Later only allow CloudFront
}

resource "aws_api_gateway_integration" "display_get" {
  type = "AWS_PROXY"
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.display.id
  http_method = aws_api_gateway_method.display_get.http_method

  integration_http_method = "POST"
  uri = aws_lambda_function.display_get_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  triggers = {
    resource_api    = jsonencode(aws_api_gateway_resource.api)
    resource_display   = jsonencode(aws_api_gateway_resource.display)
    method      = jsonencode(aws_api_gateway_method.display_get)
    integration = jsonencode(aws_api_gateway_integration.display_get)
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name = var.env
}