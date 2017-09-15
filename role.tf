resource "aws_iam_role" "iam_for_lambda" {
name = "iam_for_lambda"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "dynamoPolicy" {
name        = "dynamoPolicy"
policy      =  <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1499871122434",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:eu-west-2:${var.account}:table/vatable"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attachDynamoPolicy" {
name       = "attachDynamoPolicy"
roles      = ["${aws_iam_role.iam_for_lambda.name}"]
policy_arn = "${aws_iam_policy.dynamoPolicy.arn}"
}