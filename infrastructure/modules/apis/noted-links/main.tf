variable "api_gateway_id" {
  description = "ID of the associated aws_api_gateway_rest_api"
}

variable "api_gateway_root_resource_id" {
  description = "ID of the root resource for the associated aws_api_gateway_rest_api"
}

variable "auth0_api_gateway_authorizer" {
  description = "ID of the Auth0 API Gateway authorizer that expects Bearer token"
  default     = ""
}

resource "aws_api_gateway_resource" "noted_links" {
  path_part   = "link"
  parent_id   = "${var.api_gateway_root_resource_id}"
  rest_api_id = "${var.api_gateway_id}"
}

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id = "${var.api_gateway_id}"
  resource_id = "${aws_api_gateway_resource.noted_links.id}"
  http_method = "POST"

  authorization = "${var.auth0_api_gateway_authorizer == "" ? "NONE" : "CUSTOM"}"
  authorizer_id = "${var.auth0_api_gateway_authorizer}"
}

# Enable CORS support
module "link-cors" {
  source = "../../api-utils/cors-mappings"

  aws_region                   = "${var.aws_region}"
  api_gateway_id               = "${var.api_gateway_id}"
  api_gateway_root_resource_id = "${var.api_gateway_root_resource_id}"
  resource_id                  = "${aws_api_gateway_resource.noted_links.id}"
}
