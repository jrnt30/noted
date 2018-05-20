variable "aws_region" {}
variable "apex_environment" {}
variable "apex_function_role" {}

variable "apex_function_arns" {
  type = "map"
}

variable "apex_function_names" {
  type = "map"
}

provider "aws" {
  version = "~> 1.19"
  region  = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "dev-noted-apex"
    key    = "us/us-east-1/noted"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "account_info" {}

locals {
  account_id = "${data.aws_caller_identity.account_info.account_id}"
}

module "dynamo-table" {
  source = "../modules/dynamo"

  aws_region     = "${var.aws_region}"
  aws_account_id = "${local.account_id}"

  apex_environment    = "${var.apex_environment}"
  apex_function_role  = "${var.apex_function_role}"
  apex_function_arns  = "${var.apex_function_arns}"
  apex_function_names = "${var.apex_function_names}"
}

module "api-gateway" {
  source = "../modules/apigateway"

  aws_region     = "${var.aws_region}"
  aws_account_id = "${local.account_id}"

  apex_environment    = "${var.apex_environment}"
  apex_function_role  = "${var.apex_function_role}"
  apex_function_arns  = "${var.apex_function_arns}"
  apex_function_names = "${var.apex_function_names}"
}

module "auth0-authorizer" {
  source = "../modules/lambda-authorizer"

  aws_region     = "${var.aws_region}"
  aws_account_id = "${local.account_id}"

  apex_environment    = "${var.apex_environment}"
  apex_function_role  = "${var.apex_function_role}"
  apex_function_arns  = "${var.apex_function_arns}"
  apex_function_names = "${var.apex_function_names}"

  api_gateway_id               = "${module.api-gateway.api_gateway_id}"
  api_gateway_root_resource_id = "${module.api-gateway.api_gateway_root_resource_id}"

  apex_function_name = "auth0authorizer"
}

module "noted-apis" {
  source = "../modules/apis"

  aws_region     = "${var.aws_region}"
  aws_account_id = "${local.account_id}"

  apex_environment    = "${var.apex_environment}"
  apex_function_role  = "${var.apex_function_role}"
  apex_function_arns  = "${var.apex_function_arns}"
  apex_function_names = "${var.apex_function_names}"

  api_gateway_id               = "${module.api-gateway.api_gateway_id}"
  api_gateway_root_resource_id = "${module.api-gateway.api_gateway_root_resource_id}"
  api_gateway_role_arn         = "${module.api-gateway.api_gateway_role_arn}"
  auth0_api_gateway_authorizer = "${module.auth0-authorizer.authorizer_id}"
}
