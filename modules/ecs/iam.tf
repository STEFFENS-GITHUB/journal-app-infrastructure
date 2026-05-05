data "aws_iam_policy_document" "ecs_trust_policy_document" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_trust_policy_document.json
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_trust_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  role = aws_iam_role.ecs_execution_role.name
  policy_arn = var.ecs_execution_policy_arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = var.ecs_task_policy_arn
}