### SNS Topic: GuardDuty notifications
resource "aws_sns_topic" "guardduty" {
  # GuardDuty is not project-specific
  name = "${var.name}-GuardDuty-${var.aws_region}"

  kms_master_key_id = var.guardduty_kms_key.arn

  # Policy: ensure CloudWatch Events can publish messages
  policy = <<-POLICY
    {
      "Version": "2008-10-17",
      "Id": "GuardDuty-${var.aws_region}",
      "Statement": [
        {
          "Sid": "permit_sns_publishing",
          "Effect": "Allow",
          "Action": "sns:Publish",
          "Principal": {"Service": "events.amazonaws.com"},
          "Resource": "arn:aws:sns:${var.aws_region}:${var.aws_account}:${var.name}-GuardDuty-${var.aws_region}"
        },
        {
          "Sid": "default_policy_statement",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Action": [
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
            "SNS:Receive"
          ],
          "Resource": "arn:aws:sns:${var.aws_region}:${var.aws_account}:${var.name}-GuardDuty-${var.aws_region}",
          "Condition": {
            "StringEquals": {"AWS:SourceOwner": "${var.aws_account}"}
          }
        }
      ]
    }
    POLICY

  tags = merge(var.tags, {
    Name = "${var.name}-GuardDuty-${var.aws_region}"
  })
}

# Subscribe the topic to central SQS
resource "aws_sns_topic_subscription" "guardduty-sqs" {
  topic_arn = aws_sns_topic.guardduty.arn

  protocol = "sqs"
  endpoint = var.guardduty_sqs_arn
}

# Subscribe the PagerDuty
resource "aws_sns_topic_subscription" "pagerduty" {
  count     = length(var.guardduty_sns_https_subscriptions)
  topic_arn = aws_sns_topic.guardduty.arn

  protocol               = "https"
  endpoint               = var.guardduty_sns_https_subscriptions[count.index]
  endpoint_auto_confirms = true
}

### CloudWatch Event Rule
# Capture GuardDuty findings...
resource "aws_cloudwatch_event_rule" "guardduty" {
  name = "${var.name}-GuardDuty-Findings-${var.aws_region}"

  description = "Capture GuardDuty Detector findings"

  event_pattern = <<-PATTERN
    {
      "source": ["aws.guardduty"],
      "detail-type": ["GuardDuty Finding"]
    }
    PATTERN
}

# ... and publish them to SNS Topic
resource "aws_cloudwatch_event_target" "guardduty" {
  rule = aws_cloudwatch_event_rule.guardduty.name
  arn  = aws_sns_topic.guardduty.arn
}
