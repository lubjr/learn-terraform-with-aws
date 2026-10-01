resource "aws_sns_topic" "main" {
  name = "${var.name_prefix}-events"
}

resource "aws_sns_topic_subscription" "queue" {
  for_each = var.queues

  topic_arn            = aws_sns_topic.main.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.main[each.key].arn
  raw_message_delivery = each.value.raw_message_delivery
  filter_policy        = each.value.filter_policy == null ? null : jsonencode(each.value.filter_policy)

  depends_on = [aws_sqs_queue_policy.allow_sns]
}
