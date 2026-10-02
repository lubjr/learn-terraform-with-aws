data "archive_file" "items" {
  type        = "zip"
  source_dir  = "${path.module}/src/items"
  output_path = "${path.module}/build/items.zip"
}

resource "aws_cloudwatch_log_group" "function" {
  name              = "/aws/lambda/${var.name_prefix}-api-items"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "items" {
  function_name    = "${var.name_prefix}-api-items"
  description      = "CRUD handler for the items HTTP API"
  role             = aws_iam_role.lambda.arn
  runtime          = var.runtime
  handler          = "index.handler"
  filename         = data.archive_file.items.output_path
  source_code_hash = data.archive_file.items.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_cloudwatch_log_group.function,
  ]
}
