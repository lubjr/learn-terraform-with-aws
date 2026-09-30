output "function_names" {
  description = "Name of each Lambda function, keyed by function"
  value       = { for key, fn in aws_lambda_function.main : key => fn.function_name }
}

output "function_arns" {
  description = "ARN of each Lambda function, keyed by function"
  value       = { for key, fn in aws_lambda_function.main : key => fn.arn }
}

output "schedules" {
  description = "Schedule expression of each scheduled function"
  value       = { for key, schedule in aws_scheduler_schedule.function : key => schedule.schedule_expression }
}
