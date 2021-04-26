# aws s3 bucket
# not encrypting s3 bucket atm

resource "aws_s3_bucket" "failover_bucket" {
  bucket = "failover_bucket"
  acl    = "private"
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
    role_arn           = "value"
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

    #processing_configuration {
    #  enabled = true
    #  processors {
    #      type = "Lambda"
    #      parameters {
    #          parameter_name = "LambdaArn" 
    #          parameter_value = # Need Lambda ARN
    #      }
    #  }
    #}

    cloudwatch_logging_options {
      enabled        = true
      log_group_name = "failed_kinesis_firehose_log_group"
    }
  }

}


# lambda
resource "aws_lambda_function" "splunk_transformer" {
  function_name = "splunk_cw_transformer"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda-role.arn
}
