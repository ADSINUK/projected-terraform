### Log Bucket
resource "aws_s3_bucket" "this" {
  bucket = var.bucket

  force_destroy = true

  tags = merge(var.tags, {
    Name = var.bucket
  })
}

# S3: Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_sse ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined.json
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.elb-log-delivery.json,
    data.aws_iam_policy_document.nlb-log-delivery.json,
    data.aws_iam_policy_document.require-latest-tls.json,
    data.aws_iam_policy_document.deny-insecure-transport.json,
    data.aws_iam_policy_document.s3-log-delivery.json
  ])
}

# S3 access log delivery group
data "aws_iam_policy_document" "s3-log-delivery" {
  statement {
    sid = ""

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}


data "aws_elb_service_account" "this" {}

# AWS Load Balancer access log delivery policy
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#:~:text=Available%20bucket%20policies
data "aws_iam_policy_document" "elb-log-delivery" {
  # For regions available as of August 2022 or later
  statement {
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  # For regions available before August 2022
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.arn]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  # Outposts Zones
  statement {
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elb.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

# AWS NLB access log delivery policy
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-access-logs.html#:~:text=h2%22%2C%22http/1.1%22-,Bucket%20requirements,-When%20you%20enable
data "aws_iam_policy_document" "nlb-log-delivery" {
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

  }
}

data "aws_iam_policy_document" "deny-insecure-transport" {
  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "require-latest-tls" {
  statement {
    sid    = "denyOutdatedTLS"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket_policy.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
