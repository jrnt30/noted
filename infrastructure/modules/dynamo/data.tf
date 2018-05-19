resource "aws_dynamodb_table" "links_data" {
  name           = "${var.apex_environment}-NotedLinks"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  tags {
    Name        = "${var.apex_environment}-NotedLinks"
    Environment = "${var.apex_environment}"
  }
}

resource "aws_iam_role_policy_attachment" "dynamo-lamdba" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "${element(split("/",var.apex_function_role),1)}"
}

// Setup the dynamo -> lambda trigger
resource "aws_lambda_event_source_mapping" "dynamo_indexer_mapping" {
  event_source_arn  = "${aws_dynamodb_table.links_data.stream_arn}"
  function_name     = "${var.apex_function_arns["indexer"]}"
  starting_position = "TRIM_HORIZON"
}

resource "aws_lambda_event_source_mapping" "slack_notifier" {
  event_source_arn  = "${aws_dynamodb_table.links_data.stream_arn}"
  function_name     = "${var.apex_function_arns["notifier"]}"
  starting_position = "TRIM_HORIZON"
}
