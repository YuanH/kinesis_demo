# lambda role
data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
}

/*
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
*/

data "aws_iam_policy_document" "lambda-basic-execution-role-policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowOverflowIngestion"
    actions   = ["firehose:PutRecord"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda-basic-execution-role-policy" {
  name   = "lambda-basic-execution-role-policy"
  policy = data.aws_iam_policy_document.lambda-basic-execution-role-policy.json
}

resource "aws_iam_role_policy_attachment" "lambda-role-attachment" {
  role       = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-basic-execution-role-policy.arn
}

# Firehose role
resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "firehose_role_base_permissions" {
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.firehose_role_base_permissions.json
  name   = "firehose-base-permissions"
}

data "aws_iam_policy_document" "firehose_role_base_permissions" {
  # allows firehose stream to invoke the transform lambda
  statement {
    sid = "AllowTransformLambdaInvocation"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = ["*"]
  }
  # allows the firehose stream to write to the bucket
  statement {
    sid = "AllowBackupBucketWrite"
    actions = [
      "s3:*" # this can be refined
    ]
    resources = ["*"]
  }

  # allows the firehose delivery stream to read from its kinesis data stream
  statement {
    sid = "AllowKinesisDataStreamRead"
    actions = [
      "kinesis:*" #need to refine
    ]
    resources = ["*"]
  }

  # allows the firehose delivery stream to log delivery failures to cw log group
  statement {
    sid = "AllowCloudWatchLogsWrite"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}