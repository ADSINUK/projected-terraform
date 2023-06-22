### S3 Bucket: CloudTrail
module "s3-cloudtrail" {
  source = "../s3/"

  name                    = var.bucket
  acl                     = "private"
  force_destroy           = var.force_destroy
  enable_versioning       = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  logging = var.logging

  tags = merge(var.tags, {
    Name = var.bucket
  })
}

# Keep trail events for specified amount of time
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = module.s3-cloudtrail.bucket.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = var.expire_days
    }
  }

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    expiration {
      days = var.expire_days
    }
  }
}

# Bucket policy: Allow CloudTrail and GuardDuty to write logs to the bucket
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = var.bucket
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:GetBucketAcl",
          "Principal": {"Service": "cloudtrail.amazonaws.com"},
          "Resource": "${module.s3-cloudtrail.bucket.arn}"
        },
        {
          "Effect": "Allow",
          "Action": "s3:PutObject",
          "Principal": {"Service": "cloudtrail.amazonaws.com"},
          "Resource": "${module.s3-cloudtrail.bucket.arn}/AWSLogs/${var.aws_account}/*",
          "Condition": {
            "StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}
          }
        },
        {
          "Effect": "Deny",
          "Principal": "*",
          "Action": [
              "s3:*"
          ],
          "Resource": [
            "${module.s3-cloudtrail.bucket.arn}",
            "${module.s3-cloudtrail.bucket.arn}/AWSLogs/${var.aws_account}/*"
          ],
          "Condition": {
            "Bool": {
              "aws:SecureTransport": "false"
            }
          }
        }
      ]
    }
    POLICY

  depends_on = [module.s3-cloudtrail]
}

data "aws_partition" "current" {}

resource "aws_kms_key" "cloudtrail-cloudwatch" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  description         = "A KMS key used to encrypt CloudTrail log files stored in S3."
  enable_key_rotation = "true"
  policy              = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${var.aws_account}:trail/*"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.aws_account]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${var.aws_account}:trail/*"]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.cloudtrail-cloudwatch[0].arn
}

data "aws_iam_policy_document" "cloudtrail-assume-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# This role is used by CloudTrail to send logs to CloudWatch.
resource "aws_iam_role" "cloudtrail-cloudwatch-role" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name               = "${var.basename}-Role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail-assume-role.json
}

data "aws_iam_policy_document" "cloudtrail-cloudwatch-logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${var.aws_account}:log-group:${var.cloudwatch_log_group_name}:*"]
  }
}

resource "aws_iam_policy" "cloudtrail-cloudwatch-logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name   = "${var.basename}-Policy"
  policy = data.aws_iam_policy_document.cloudtrail-cloudwatch-logs.json
}

resource "aws_iam_policy_attachment" "main" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail-cloudwatch-logs[0].arn
  roles      = [aws_iam_role.cloudtrail-cloudwatch-role[0].name]
}

### CloudTrail
resource "aws_cloudtrail" "main" {
  # Trails are not project-specific
  name = var.basename

  # Write events to central bucket
  s3_bucket_name = var.bucket

  # Log events from all regions
  is_multi_region_trail = true

  # Create KMS key to use to encrypt the logs delivered by CloudTrail.
  kms_key_id = var.enable_kms_encryption ? aws_kms_key.cloudtrail[0].arn : ""

  # Log file integrity validation
  enable_log_file_validation = var.log_file_validation

  # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_group_arn = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail-cloudwatch-role[0].arn : null

  tags = merge(var.tags, {
    Name = var.basename
  })

  # There is no implicit dependency
  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

### KMS Key: CloudTrail
resource "aws_kms_key" "cloudtrail" {
  count = var.enable_kms_encryption ? 1 : 0

  description = "Key for CloudTrail findings encryption"

  enable_key_rotation = var.kms_key_rotation

  # Allow key usage by CloudTrail and account users
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "kms:GenerateDataKey",
        "Principal": {"Service": "cloudtrail.amazonaws.com"},
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "kms:*",
        "Principal": {"AWS": "arn:aws:iam::${var.aws_account}:root"},
        "Resource": "*"
      }
    ]
  }
  EOF
  tags = merge(var.tags, {
    Name = var.basename
  })
  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# KMS Key: Alias
resource "aws_kms_alias" "cloudtrail" {
  count = var.enable_kms_encryption ? 1 : 0

  name          = "alias/${var.basename}"
  target_key_id = aws_kms_key.cloudtrail[0].id
}
