variable "api_gateway_id" {}

variable "api_resource_id" {}

variable "api_resource_method_http_method" {}

resource "aws_api_gateway_method_response" "standard_200" {
  rest_api_id = "${var.api_gateway_id}"
  resource_id = "${var.api_resource_id}"

  http_method = "${var.api_resource_method_http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty" // default model
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}
