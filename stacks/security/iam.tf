data "aws_caller_identity" "current_identity" {}

data "aws_iam_policy_document" "rds_kms_policy" {
  statement {
    sid = "AllowAccountAdmin"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current_identity.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowRDSUse"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "rds_master_user_kms_policy" {
  statement {
    sid = "AllowAccountAdmin"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current_identity.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowSecretsManagerUse"
    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_execution_permissions_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"] # More specific
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"] # More specific
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = ["*"] # More specific
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"] # Specify more clearly
  }
}

data "aws_iam_policy_document" "ecs_task_policy_document" {

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = ["*"] # Specify more clearly
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"] # Specify more clearly
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"] # Specify more clearly
  }
}

data "aws_iam_policy_document" "display_get_lambda_execution_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "github_actions_trust_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:STEFFENS-GITHUB/journal-app-lambda:*"] # Parameterize this later
    }
  }
}

data "aws_iam_policy_document" "github_actions_execution_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/lambda-artifacts/display-get/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::display-get-lambda-*/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["lambda:UpdateFunctionCode", "lambda:GetFunction"]
    resources = ["arn:aws:lambda:*:*:function:display-get-lambda"]
  }
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name   = "ecs-execution-policy"
  policy = data.aws_iam_policy_document.ecs_execution_permissions_policy_document.json
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task_policy_document.json
}

resource "aws_iam_policy" "display_get_execution_policy" {
  name   = "display-get-lambda-logs"
  policy = data.aws_iam_policy_document.display_get_lambda_execution_policy_document.json
}

resource "aws_iam_role" "github_actions_role" {
  name               = "github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust_policy_document.json
}

resource "aws_iam_policy" "github_actions_policy" {
  name   = "github-actions-policy"
  policy = data.aws_iam_policy_document.github_actions_execution_policy_document.json
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}