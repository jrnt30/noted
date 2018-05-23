variable "aws_region" {
  description = "AWS Region to deploy resources to"
}

variable "aws_account_id" {}

variable "apex_environment" {}
variable "apex_function_role" {}

variable "apex_function_arns" {
  type = "map"
}

variable "apex_function_names" {
  type = "map"
}
