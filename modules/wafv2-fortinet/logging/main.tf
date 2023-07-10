resource "aws_iam_role" "kinesis" {
  name = "${var.name}-Kinesis-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-Kinesis-Role"
  })
}

resource "aws_iam_policy" "kinesis-s3" {
  name = "${var.name}-Kinesis-S3-Policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Effect = "Allow"
        Resource = [
          var.log_bucket_arn,
          "${var.log_bucket_arn}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "iam-lambda-kubernetes-network-attach" {
  name       = "${var.name}-Kinesis-S3-Policy-Attachment"
  roles      = [aws_iam_role.kinesis.name]
  policy_arn = aws_iam_policy.kinesis-s3.arn
}

resource "aws_kinesis_firehose_delivery_stream" "delivery-stream" {
  name        = "aws-waf-logs-${var.name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis.arn
    bucket_arn = var.log_bucket_arn

    prefix = "waf/${var.name}/"
  }

  server_side_encryption {
    enabled  = var.encryption_enabled
    key_type = var.encryption_key_type
    key_arn  = var.encryption_key_arn
  }

  tags = merge(var.tags, {
    Name = "aws-waf-logs-${var.name}"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "logging-conf" {
  resource_arn            = var.waf_acl_arn
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.delivery-stream.arn]

  redacted_fields {
    query_string {}
  }
  redacted_fields {
    uri_path {}
  }
  redacted_fields {
    method {}
  }
}

# vim:filetype=terraform ts=2 sw=2 et:
