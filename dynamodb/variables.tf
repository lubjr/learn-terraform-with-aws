variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "learn-terraform-items"
}

variable "ttl_attribute" {
  description = "Attribute holding the expiration time (Unix epoch seconds) of an item"
  type        = string
  default     = "expires_at"
}

variable "point_in_time_recovery" {
  description = "Enable continuous backups (billed per GB-month, not covered by the Free Tier)"
  type        = bool
  default     = false
}
