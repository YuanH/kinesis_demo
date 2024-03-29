# aws s3 bucket
# not encrypting s3 bucket atm

resource "aws_s3_bucket" "failover_bucket" {
  bucket = "failover-us-east-1-bucket"
  acl    = "private"
}


# Cloudwatch Log Group and Log Stream
resource "aws_cloudwatch_log_group" "log_group" {
  name = "failed_kinesis_firehose_log_group"
}


resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "failed_kinesis_firehose_log_stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

# Kinesis Stream
resource "aws_kinesis_stream" "kinesis-stream" {
  name        = "kinesis_stream"
  shard_count = 8
}

# Firehose
resource "aws_kinesis_firehose_delivery_stream" "kinesis-firehose" {
  name        = "kinesis_firehose"
  destination = "splunk"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis-stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.failover_bucket.arn
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
  }


  splunk_configuration {
    hec_endpoint               = var.hec_endpoint
    hec_token                  = var.hec_token
    hec_acknowledgment_timeout = 600
    hec_endpoint_type          = "Event"
    s3_backup_mode             = "FailedEventsOnly"

    processing_configuration {
      enabled = true
      processors {
          type = "Lambda"
          parameters {
            parameter_name = "LambdaArn" 
            parameter_value = "${aws_lambda_function.splunk_transformer.arn}:$LATEST"
          }
          parameters {
            parameter_name = "RoleArn"
            parameter_value = aws_iam_role.firehose_role.arn
          }
      }
    }

    cloudwatch_logging_options {
      enabled        = true
      log_group_name = "failed_kinesis_firehose_log_group"
      log_stream_name = "failed_kinesis_firehose_log_stream"
    }
  }
}


# lambda
resource "aws_lambda_function" "splunk_transformer" {
  function_name = var.lambda_function_name
  description = "Transform data from kinesis firehose to splunk compatible format"
  handler       = "${var.lambda_function_name}.lambda_handler"
  role          = aws_iam_role.kinesis_firehose_lambda.arn
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime = "python3.8"
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/files/${var.lambda_function_name}.py"
  output_path = "${path.module}/files/${var.lambda_function_name}.zip"
}