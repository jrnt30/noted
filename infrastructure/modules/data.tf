resource "aws_dynamodb_table" "links-data" {
  name           = "${var.apex_environment}-NotedLinks"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  tags {
    Name        = "${var.apex_environment}-NotedLinks"
    Environment = "${var.apex_environment}"
  }
}

resource "aws_iam_role_policy_attachment" "dynamo-lamdba" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "${element(split("/",var.apex_function_role),1)}"
}
