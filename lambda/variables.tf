variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "learn-terraform-hello"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs24.x"
}

variable "log_retention_days" {
  description = "Number of days to retain the function logs in CloudWatch"
  type        = number
  default     = 14
}
