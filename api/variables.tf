variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for the API, function, table and role names"
  type        = string
  default     = "learn-terraform"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs24.x"
}

variable "log_retention_days" {
  description = "Number of days to retain the function and access logs in CloudWatch"
  type        = number
  default     = 14
}

variable "throttling_rate_limit" {
  description = "Steady-state requests per second allowed on every route"
  type        = number
  default     = 5
}

variable "throttling_burst_limit" {
  description = "Maximum number of concurrent requests allowed on every route"
  type        = number
  default     = 10
}
