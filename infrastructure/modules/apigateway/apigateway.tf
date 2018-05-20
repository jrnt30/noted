resource "aws_api_gateway_rest_api" "noted_api" {
  name        = "${var.apex_environment}-noted-api-gateway"
  description = "API Gateway for noted"
}

output "api_gateway_id" {
  value = "${aws_api_gateway_rest_api.noted_api.id}"
}

output "api_gateway_root_resource_id" {
  value = "${aws_api_gateway_rest_api.noted_api.root_resource_id}"
}

# DNS
# Domain


# https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html
# https://medium.com/@MrPonath/terraform-and-aws-api-gateway-a137ee48a8ac


# Auth
# aws_api_gateway_authorizer


# aws_api_gateway_deployment
# aws_api_gateway_domain_name
# aws_api_gateway_base_path_mapping

