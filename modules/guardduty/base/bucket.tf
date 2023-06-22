### S3 Bucket: GuardDuty
module "s3-guardduty" {
  source = "../../s3/"

  name                    = var.bucket
  acl                     = "private"
  force_destroy           = var.force_destroy
  enable_encryption       = true
  use_kms                 = false
  enable_versioning       = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = merge(var.tags, {
    Name = var.bucket
  })
}

# Load access logs of General bucket to Log bucket
resource "aws_s3_bucket_logging" "logging" {
  bucket = module.s3-guardduty.bucket.id

  target_bucket = var.log_bucket_id
  target_prefix = "s3/${var.bucket}/"
}

# Keep trail events for specified amount of time
resource "aws_s3_bucket_lifecycle_configuration" "guardduty" {
  bucket = module.s3-guardduty.bucket.id

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
resource "aws_s3_bucket_policy" "guardduty" {
  bucket = var.bucket
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ],
          "Principal": {"Service": "guardduty.amazonaws.com"},
          "Resource": "${module.s3-guardduty.bucket.arn}"
        },
        {
          "Effect": "Allow",
          "Action": "s3:PutObject",
          "Principal": {"Service": "guardduty.amazonaws.com"},
          "Resource": "${module.s3-guardduty.bucket.arn}/AWSLogs/*",
          "Condition": {
            "StringEquals": {"s3:x-amz-server-side-encryption": "aws:kms"}
          }
        }
      ]
    }
    POLICY
}
