variable "api_gateway_id" {
  description = "ID of the associated aws_api_gateway_rest_api"
}

variable "api_gateway_root_resource_id" {
  description = "ID of the root resource for the associated aws_api_gateway_rest_api"
}

variable "api_gateway_role_arn" {}

variable "auth0_api_gateway_authorizer" {
  description = "ID of the Auth0 API Gateway authorizer that expects Bearer token"
  default     = ""
}

locals {
  noted_uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.apex_function_arns["noted"]}/invocations"
}

resource "aws_api_gateway_resource" "noted_links" {
  path_part   = "link"
  parent_id   = "${var.api_gateway_root_resource_id}"
  rest_api_id = "${var.api_gateway_id}"
}

resource "aws_api_gateway_method" "links_post" {
  rest_api_id   = "${var.api_gateway_id}"
  resource_id   = "${aws_api_gateway_resource.noted_links.id}"
  http_method   = "POST"
  authorization = "${var.auth0_api_gateway_authorizer == "" ? "NONE" : "CUSTOM"}"
  authorizer_id = "${var.auth0_api_gateway_authorizer}"
}

resource "aws_api_gateway_integration" "endpoint_integration" {
  rest_api_id             = "${var.api_gateway_id}"
  resource_id             = "${aws_api_gateway_resource.noted_links.id}"
  http_method             = "${aws_api_gateway_method.links_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.noted_uri}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway-noted"
  action        = "lambda:InvokeFunction"
  function_name = "${var.apex_function_arns["noted"]}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${var.api_gateway_id}/*/${aws_api_gateway_method.links_post.http_method}${aws_api_gateway_resource.noted_links.path}"
}

# Enable CORS support
module "link-cors" {
  source = "../api-utils/cors-mappings"

  aws_region                   = "${var.aws_region}"
  api_gateway_id               = "${var.api_gateway_id}"
  api_gateway_root_resource_id = "${var.api_gateway_root_resource_id}"
  resource_id                  = "${aws_api_gateway_resource.noted_links.id}"
}
