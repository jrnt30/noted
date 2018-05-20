resource "aws_api_gateway_rest_api" "noted_api" {
  name        = "${var.apex_environment}-noted-api-gateway"
  description = "API Gateway for noted"
}

resource "aws_iam_role" "api_gateway_role" {
  name = "${var.apex_environment}-api_gateway_lambda"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "${var.apex_environment}-invoke-lambdas"
  role = "${aws_iam_role.api_gateway_role.id}"

  # Join hack from: https://github.com/hashicorp/terraform/issues/8879#issuecomment-277398328
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": ["${join("\",\"", values(var.apex_function_arns))}"]
    }
  ]
}
EOF
}

output "api_gateway_id" {
  value = "${aws_api_gateway_rest_api.noted_api.id}"
}

output "api_gateway_root_resource_id" {
  value = "${aws_api_gateway_rest_api.noted_api.root_resource_id}"
}

output "api_gateway_role_arn" {
  value = "${aws_iam_role.api_gateway_role.arn}"
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

