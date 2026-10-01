variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for the topic and queue names"
  type        = string
  default     = "learn-terraform"
}

variable "queues" {
  description = "Queues subscribed to the topic, keyed by name. Set filter_policy to receive only messages whose attributes match it"
  type = map(object({
    filter_policy        = optional(map(list(string)))
    raw_message_delivery = optional(bool, true)
  }))
  default = {
    all = {}
    high-priority = {
      filter_policy = { priority = ["high"] }
    }
  }
}

variable "visibility_timeout_seconds" {
  description = "Time a received message stays hidden from other consumers before it can be received again"
  type        = number
  default     = 30
}

variable "max_receive_count" {
  description = "Number of times a message can be received without being deleted before it moves to the dead-letter queue"
  type        = number
  default     = 3
}
