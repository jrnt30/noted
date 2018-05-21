variable "api_gateway_id" {
  description = "ID of the associated aws_api_gateway_rest_api"
}

variable "api_gateway_root_resource_id" {
  description = "ID of the root resource for the associated aws_api_gateway_rest_api"
}

variable "resource_id" {
  description = "ID of the actual rest api resource that is getting modified"
}

# CORS support for endpoint
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = "${var.api_gateway_id}"
  resource_id   = "${var.resource_id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = "${var.api_gateway_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  status_code = "200"

  response_models {
    "application/json" = "Empty"
  }

  response_parameters {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id          = "${var.api_gateway_id}"
  resource_id          = "${var.resource_id}"
  http_method          = "${aws_api_gateway_method.options_method.http_method}"
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates {
    "application/json" = "{ 'statusCode': 200 }"
  }

  depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = "${var.api_gateway_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.options_200.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.options_200"]
}
