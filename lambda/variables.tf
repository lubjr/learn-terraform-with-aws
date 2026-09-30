variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for the function names and the shared IAM roles"
  type        = string
  default     = "learn-terraform"
}

variable "functions" {
  description = "Functions to deploy, keyed by the folder name under src/. Set schedule to run the function on an EventBridge Scheduler expression"
  type = map(object({
    description = string
    schedule    = optional(string)
  }))
  default = {
    hello = {
      description = "Returns a greeting for the given name"
    }
    heartbeat = {
      description = "Logs a heartbeat on a fixed schedule"
      schedule    = "rate(5 minutes)"
    }
  }
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
