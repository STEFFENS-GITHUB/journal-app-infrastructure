# -------------- Journal Lambda Pipeline IAM --------------

data "aws_iam_policy_document" "journal_lambda_deploy_trust" {
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
      values   = ["repo:STEFFENS-GITHUB/journal-app-lambda:*"]
    }
  }
}

data "aws_iam_policy_document" "journal_lambda_deploy_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/lambda-artifacts/display-get/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject","s3:GetObject"]
    resources = ["arn:aws:s3:::display-get-lambda-*/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["lambda:UpdateFunctionCode", "lambda:GetFunction", "lambda:UpdateFunctionConfiguration", "lambda:GetFunctionConfiguration", "lambda:UpdateAlias"]
    resources = ["arn:aws:lambda:*:*:function:display-get-lambda"]
  }
  statement {
    effect    = "Allow"
    actions   = ["lambda:PublishLayerVersion", "lambda:GetLayerVersion"]
    resources = ["arn:aws:lambda:*:*:layer:display-get-lambda-deps", "arn:aws:lambda:*:*:layer:display-get-lambda-deps:*"]
  }
}

resource "aws_iam_role" "journal_lambda_deploy" {
  name               = "journal-lambda-deploy"
  assume_role_policy = data.aws_iam_policy_document.journal_lambda_deploy_trust.json
}

resource "aws_iam_policy" "journal_lambda_deploy" {
  name   = "journal-lambda-deploy"
  policy = data.aws_iam_policy_document.journal_lambda_deploy_permissions.json
}

resource "aws_iam_role_policy_attachment" "journal_lambda_deploy" {
  role       = aws_iam_role.journal_lambda_deploy.name
  policy_arn = aws_iam_policy.journal_lambda_deploy.arn
}

# -------------- Infra Pipeline IAM above --------------

data "aws_iam_policy_document" "infra_deploy_trust" {
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
      values   = ["repo:STEFFENS-GITHUB/journal-app-infrastructure:*"]
    }
  }
}

resource "aws_iam_role" "infra_deploy" {
  name               = "infra-deploy"
  assume_role_policy = data.aws_iam_policy_document.infra_deploy_trust.json
}

resource "aws_iam_role_policy_attachment" "infra_deploy" {
  role       = aws_iam_role.infra_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}