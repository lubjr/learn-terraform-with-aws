locals {
  scheduled_functions = {
    for key, fn in var.functions : key => fn
    if fn.schedule != null
  }
}

data "archive_file" "function" {
  for_each = var.functions

  type        = "zip"
  source_dir  = "${path.module}/src/${each.key}"
  output_path = "${path.module}/build/${each.key}.zip"
}

resource "aws_cloudwatch_log_group" "function" {
  for_each = var.functions

  name              = "/aws/lambda/${var.name_prefix}-${each.key}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "main" {
  for_each = var.functions

  function_name    = "${var.name_prefix}-${each.key}"
  description      = each.value.description
  role             = aws_iam_role.lambda.arn
  runtime          = var.runtime
  handler          = "index.handler"
  filename         = data.archive_file.function[each.key].output_path
  source_code_hash = data.archive_file.function[each.key].output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_cloudwatch_log_group.function,
  ]
}

moved {
  from = aws_lambda_function.main
  to   = aws_lambda_function.main["hello"]
}

moved {
  from = aws_cloudwatch_log_group.function
  to   = aws_cloudwatch_log_group.function["hello"]
}
