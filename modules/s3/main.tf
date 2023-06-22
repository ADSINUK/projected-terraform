locals {
  bucket_name             = lower(var.name)
  replication_bucket_name = lookup(var.replication, "bucket", null)
}

### Create IAM role for bucket replication
resource "aws_iam_role" "s3-replication" {
  count = length(keys(var.replication)) == 0 ? 0 : 1

  name = "${local.bucket_name}_replication_role"

  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "S3ReplicationPolicy"
      }
    ]
  }
  POLICY
}

resource "aws_iam_policy" "s3-replication" {
  count = length(keys(var.replication)) == 0 ? 0 : 1

  name = "${local.bucket_name}_replication_policy"

  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${local.replication_bucket_name}"
        ]
      },
      {
        "Action": [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${local.replication_bucket_name}/*"
        ]
      },
      {
        "Action": [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${local.replication_bucket_name}/*"
      }
    ]
  }
  POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  count = length(keys(var.replication)) == 0 ? 0 : 1

  name       = "${local.bucket_name}_replication_role"
  roles      = [aws_iam_role.s3-replication[0].name]
  policy_arn = aws_iam_policy.s3-replication[0].arn
}

### Create S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_acl" "this" {
  bucket     = aws_s3_bucket.this.id
  acl        = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.ownership]
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.attach_policy_website ? 1 : 0
  bucket = aws_s3_bucket.this.bucket
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = var.enable_cors ? 1 : 0
  bucket = aws_s3_bucket.this.bucket

  dynamic "cors_rule" {
    for_each = try(jsondecode(var.cors_rule), var.cors_rule)
    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning || (length(keys(var.replication)) > 0) ? 1 : 0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3: Encryption
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "aws-kms-key-s3" {
  count        = var.enable_encryption == true && var.kms_arn == null && var.use_kms == true ? 1 : 0
  source       = "../kms-key"
  name         = local.bucket_name
  description  = "Key for S3 encryption"
  aws_services = ["s3"]
  key_rotation = var.kms_rotation
  aws_region   = data.aws_region.current.name
  aws_account  = data.aws_caller_identity.current.account_id
  tags = merge(var.tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_arn != null ? "aws:kms" : var.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_arn != null ? var.kms_arn : try(module.aws-kms-key-s3[0].key.arn, null)
    }
    bucket_key_enabled = try(var.use_kms, true)
  }
}

### Need to addjust kms key policy
resource "aws_s3_bucket_replication_configuration" "this" {
  count = length(keys(var.replication)) > 0 ? 1 : 0

  role   = aws_iam_role.s3-replication[0].arn
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = [var.replication]
    content {
      id       = "replication-to-${local.replication_bucket_name}"
      priority = "0"
      prefix   = lookup(var.replication, "prefix", null)
      status   = "Enabled"

      destination {
        bucket  = var.replication.bucket
        account = lookup(var.replication, "dest_account_id", null)
      }
    }
  }
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_policy" "this" {
  count = var.attach_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined[0].json
}

data "aws_iam_policy_document" "combined" {
  count = var.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.deny_insecure_transport ? data.aws_iam_policy_document.deny-insecure-transport[0].json : "",
    var.attach_policy_website ? data.aws_iam_policy_document.allow-website[0].json : "",
    var.attach_policy ? var.policy : ""
  ])
}

data "aws_iam_policy_document" "deny-insecure-transport" {
  count = var.deny_insecure_transport ? 1 : 0
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

data "aws_iam_policy_document" "allow-website" {
  count = var.attach_policy_website ? 1 : 0
  statement {
    sid    = "StaticWebsite"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  # Chain resources (s3_bucket -> s3_bucket_policy -> s3_bucket_public_access_block)
  bucket = var.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this.id

  block_public_acls       = !var.attach_policy_website && var.block_public_acls ? true : false
  block_public_policy     = !var.attach_policy_website && var.block_public_policy ? true : false
  ignore_public_acls      = !var.attach_policy_website && var.ignore_public_acls ? true : false
  restrict_public_buckets = !var.attach_policy_website && var.restrict_public_buckets ? true : false
}

resource "aws_s3_bucket_logging" "logging" {
  count = length(keys(var.logging)) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging["target_bucket"]
  target_prefix = try(var.logging["target_prefix"], null)
}

# True - BucketOwnerPreferred, false - ObjectWriter, BucketOwnerEnforced

resource "aws_s3_bucket_ownership_controls" "ownership" {

  count  = var.ownership_s3_control ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership ? "BucketOwnerPreferred" : "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {

  count  = length(keys(var.lifecycle_rule)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = length(keys(var.lifecycle_rule)) == 0 ? [] : [var.lifecycle_rule]

    content {
      id     = lookup(rule.value, "id", null)
      status = lookup(rule.value, "status", null)

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [lookup(rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(rule.value, "noncurrent_version_expiration", {})]

        content {
          noncurrent_days = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])

        content {
          noncurrent_days = lookup(noncurrent_version_transition.value, "noncurrent_days ", null)
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = length(keys(lookup(rule.value, "abort_incomplete_multipart_upload", {}))) == 0 ? [] : [lookup(rule.value, "abort_incomplete_multipart_upload", {})]

        content {
          days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation", null)
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}
