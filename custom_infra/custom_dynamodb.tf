resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.custom_env}-app-dynamo-table-ayu-test-heheh"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserID"

  attribute {
    name = "UserID"
    type = "S"
  }
  
  tags = {
    Name        = "${var.custom_env}-app-dynamo-table-ayu-test-heheh"
    Environment = var.custom_env
  }
}
