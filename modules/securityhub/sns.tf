### Data block 
data "aws_region" "this" {}
data "aws_caller_identity" "current" {}

### Create AWS SNS topic
resource "aws_sns_topic" "securityhub" {
  count             = var.alarm_email != "" ? 1 : 0
  kms_master_key_id = aws_kms_alias.securityhub.arn
  name              = "${lower(var.sns_name)}-${lower(var.project_name)}"
  display_name      = "${lower(var.sns_name)}-${lower(var.project_name)}"
}

### Create AWS SNS topic
resource "aws_sns_topic" "securityhub-to-email" {
  count        = var.summary_email != "" ? 1 : 0
  name         = "summary-${lower(var.sns_name)}-${lower(var.project_name)}"
  display_name = "summary-${lower(var.sns_name)}-${lower(var.project_name)}"
}

### Create AWS SNS topic subscription to EMAIL endpoint
resource "aws_sns_topic_subscription" "summury-email" {
  count     = var.summary_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.securityhub-to-email[0].arn
  protocol  = "email"
  endpoint  = try(var.summary_email, "")
}

### Create AWS SNS topic policies
resource "aws_sns_topic_policy" "sns-topic-policy" {
  count  = var.alarm_email != "" || var.summary_email != "" ? 1 : 0
  arn    = aws_sns_topic.securityhub[0].arn
  policy = data.aws_iam_policy_document.sns-topic-policy[0].json
}

data "aws_iam_policy_document" "sns-topic-policy" {
  count = var.alarm_email != "" || var.summary_email != "" ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sns_topic.securityhub[0].arn]
  }
}

### Create AWS SNS topic subscription to EMAIL endpoint
resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.securityhub[0].arn
  protocol  = "email"
  endpoint  = try(var.alarm_email, "")
}

### KMS Key: Securityhub
resource "aws_kms_key" "securityhub" {
  description = "Key for Securityhub encryption"

  # Specifies whether key rotation is enabled
  enable_key_rotation = true

  # Allow key usage by Securityhub and account users
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:ListAliases"
        ],
        "Principal": {
           "Service": [
              "lambda.amazonaws.com",
              "events.amazonaws.com",
              "cloudwatch.amazonaws.com"
           ]
        },
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "kms:*",
        "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
        "Resource": "*"
      }
    ]
  }
    EOF
}

# User-friendly key alias
resource "aws_kms_alias" "securityhub" {
  name          = "alias/securityhub-${data.aws_region.this.name}"
  target_key_id = aws_kms_key.securityhub.id
}
