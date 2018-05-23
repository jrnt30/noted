variable "api_gateway_id" {
  description = "ID of the associated aws_api_gateway_rest_api"
}

variable "api_gateway_root_resource_id" {
  description = "ID of the root resource for the associated aws_api_gateway_rest_api"
}

variable "apex_function_name" {
  description = "Name of the Apex function to create the authorizer with"
}

# Need to invoke_arn which is not currently explicitly passed in
# via apex
data "aws_lambda_function" "authorizer" {
  function_name = "${var.apex_function_names["${var.apex_function_name}"]}"
}

# Ensure API Gateway can call authorizer
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway-${var.apex_function_name}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.apex_function_arns["${var.apex_function_name}"]}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:515560697729:${var.api_gateway_id}/authorizers/${aws_api_gateway_authorizer.authorizer.id}"
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name        = "${var.apex_function_name}"
  rest_api_id = "${var.api_gateway_id}"

  # Well this wasn't particularly fun to figure out.  The datasource appends a `:$LATEST` specifier
  # in the invocation arn which breaks the permission structure here
  authorizer_uri = "${replace(data.aws_lambda_function.authorizer.invoke_arn, ":$LATEST", "")}"

  authorizer_credentials = "${aws_iam_role.invocation_role.arn}"
}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
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
  name = "default"
  role = "${aws_iam_role.invocation_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${var.apex_function_arns["${var.apex_function_name}"]}"
    }
  ]
}
EOF
}

output "authorizer_id" {
  value = "${aws_api_gateway_authorizer.authorizer.id}"
}
