### GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  enable = true
  datasources {
    s3_logs {
      enable = var.s3_protection
    }
    kubernetes {
      audit_logs {
        enable = var.eks_protection
      }
    }
  }
}

# Publish findings to S3 bucket
resource "aws_guardduty_publishing_destination" "guardduty-publisher" {
  detector_id     = aws_guardduty_detector.main.id
  destination_arn = var.bucket.arn
  kms_key_arn     = var.guardduty_kms_key.arn
}
