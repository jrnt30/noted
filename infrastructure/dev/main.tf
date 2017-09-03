variable "aws_region" {}
variable "apex_environment" {}
//variable "apex_function_role" {}
//variable "apex_function_names" {}
//variable "apex_function_arns" {}

terraform {
  backend "s3" {
    bucket = "noted-apex-tf-state"
    key = "dev/us-east-1/noted"
    region = "us-east-1"
  }
}

module "dynamo-table" {
  source = "../modules/"

  apex_environment = "${var.apex_environment}"
  aws_region = "${var.aws_region}"
}
