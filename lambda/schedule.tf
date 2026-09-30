resource "aws_scheduler_schedule" "function" {
  for_each = local.scheduled_functions

  name                = "${var.name_prefix}-${each.key}"
  schedule_expression = each.value.schedule

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.main[each.key].arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ source = "scheduler" })
  }
}
