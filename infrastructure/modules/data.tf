resource "aws_dynamodb_table" "links-data" {
  name = "${var.apex_environment}-NotedLinks"
  read_capacity = 5
  write_capacity = 5
  hash_key = "Url"
  range_key = "CreatedAt"

  attribute {
    name = "Url"
    type = "S"
  }

  attribute {
    name = "Title"
    type = "S"
  }

  attribute {
    name = "Description"
    type = "S"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }

  attribute {
    name = "DeletedAt"
    type = "N"
  }

  attribute {
    name = "UpdatedAt"
    type = "N"
  }

  tags {
    Name = "${var.apex_environment}-NotedLinks"
    Environment = "${var.apex_environment}"
  }
}
