data "aws_iam_policy_document" "display_get_lambda_trust_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "display_get_lambda_execution_role" {
  name               = "display-get-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.display_get_lambda_trust_policy_document.json
}
resource "aws_iam_role_policy_attachment" "display_get_lambda_trust_policy_attachment" {
  role       = aws_iam_role.display_get_lambda_execution_role.name
  policy_arn = data.terraform_remote_state.security_state.outputs.display_get_execution_policy_arn
}