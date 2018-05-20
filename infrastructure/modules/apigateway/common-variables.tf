variable "aws_region" {
  description = "AWS Region to deploy resources to"
}

variable "apex_environment" {}
variable "apex_function_role" {}

variable "apex_function_arns" {
  type = "map"
}

variable "apex_function_names" {
  type = "map"
}
