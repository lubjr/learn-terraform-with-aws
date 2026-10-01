output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.main.arn
}

output "queue_urls" {
  description = "URL of each queue, keyed by queue"
  value       = { for key, queue in aws_sqs_queue.main : key => queue.url }
}

output "dlq_urls" {
  description = "URL of each dead-letter queue, keyed by queue"
  value       = { for key, queue in aws_sqs_queue.dlq : key => queue.url }
}
