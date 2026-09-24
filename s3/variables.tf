variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name (AWS appends a unique suffix)"
  type        = string
  default     = "learn-terraform-"
}
