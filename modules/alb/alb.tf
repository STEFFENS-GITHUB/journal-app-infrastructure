resource "aws_lb" "load_balancer" {
  name               = "alb-${var.env}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_ids
  subnets            = var.public_subnet_ids
  tags = {
    Name = "alb-${var.env}"
    Environment = var.env
  }
}

resource "aws_lb_target_group" "target_group" {
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    Name = "target-group-${var.env}"
    Environment = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# resource "aws_lb_listener" "https_listener" {
#     load_balancer_arn = aws_lb.ecs-lb.arn
#     port = 443
#     protocol = "HTTPS"
#     ssl_policy = # FILL IN HERE
#     certificate_arn = # FILL IN HERE
#         default_action {
#         type = "forward"
#         target_group_arn = aws_lb_target_group.ecs_vote_target_group.arn
#     }
# }