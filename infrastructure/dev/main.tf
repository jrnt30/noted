variable "aws_region" {}
variable "apex_environment" {}
variable "apex_function_role" {}

variable "apex_function_arns" {
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

module "dynamo-table" {
  source = "../modules/dynamo"

  apex_environment   = "${var.apex_environment}"
  aws_region         = "${var.aws_region}"
  apex_function_role = "${var.apex_function_role}"
  apex_function_arns = "${var.apex_function_arns}"
}
