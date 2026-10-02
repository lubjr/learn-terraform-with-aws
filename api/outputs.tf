output "api_url" {
  description = "Base URL of the HTTP API"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "function_name" {
  description = "Name of the Lambda function behind the API"
  value       = aws_lambda_function.items.function_name
}

output "table_name" {
  description = "Name of the DynamoDB table holding the items"
  value       = aws_dynamodb_table.items.name
}
