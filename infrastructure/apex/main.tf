# Some account level IAM stuff that
# `apex init` usually covers, but since we want to be
# able to run this in other accounts, adding in explict
# "apex" environment
terraform {
  backend "s3" {
    bucket = "dev-noted-apex"
    key    = "us/us-east-1/apex/"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lamdba-role" {
  name = "lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda-log-access" {
  name        = "lambda-log-access"
  path        = "/"
  description = "Default policy for lambdas"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-logs-attach" {
  role       = "${aws_iam_role.lamdba-role.name}"
  policy_arn = "${aws_iam_policy.lambda-log-access.arn}"
}
