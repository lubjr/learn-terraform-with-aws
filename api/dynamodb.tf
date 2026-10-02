resource "aws_dynamodb_table" "items" {
  name         = "${var.name_prefix}-api-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
