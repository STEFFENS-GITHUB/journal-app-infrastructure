resource "aws_security_group" "ecs-lb-sg" {
  name   = "ecs-lb-sg"
  vpc_id = var.vpc_id

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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ecs-lb" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs-lb-sg.id]
  subnets            = var.public_subnet_ids
  tags = {
    Name = "ecs-voting-app-lb"
  }
}

resource "aws_lb_target_group" "ecs_vote_target_group" {
  name        = "ecs-vote-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    Name = "ecs-vote-tg"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_vote_target_group.arn
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