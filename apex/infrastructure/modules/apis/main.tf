variable "api_gateway_id" {
  description = "ID of the associated aws_api_gateway_rest_api"
}

variable "api_gateway_root_resource_id" {
  description = "ID of the root resource for the associated aws_api_gateway_rest_api"
}

variable "api_gateway_role_arn" {}

variable "auth0_api_gateway_authorizer" {
  description = "ARN for the API Gateway authorizer"
  default     = ""
}

module "noted-links" {
  source = "./noted-links"

  aws_region     = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"

  apex_environment    = "${var.apex_environment}"
  apex_function_role  = "${var.apex_function_role}"
  apex_function_arns  = "${var.apex_function_arns}"
  apex_function_names = "${var.apex_function_names}"

  api_gateway_id               = "${var.api_gateway_id}"
  api_gateway_root_resource_id = "${var.api_gateway_root_resource_id}"
  api_gateway_role_arn         = "${var.api_gateway_role_arn}"

  auth0_api_gateway_authorizer = "${var.auth0_api_gateway_authorizer}"
}
