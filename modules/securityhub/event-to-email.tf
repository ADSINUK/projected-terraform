# Event to email
resource "aws_cloudwatch_event_rule" "securityhub" {
  count       = var.alarm_email != "" || var.alarm_slack_endpoint != "" ? 1 : 0
  name_prefix = "SecurityHubFindings"
  description = "A CloudWatch Event Rule that triggers on AWS Security Hub findings"

  event_pattern = <<EOF
{
  "detail-type": [
    "Security Hub Findings - Imported"
  ],
  "source": [
    "aws.securityhub"
  ],
  "detail": {
    "findings": {
      "Severity": {
        "Label": ${jsonencode(var.severity_list)}
      },
      "RecordState": ["ACTIVE"],
      "Workflow": {
        "Status": [
          "NEW",
          "NOTIFIED"
        ]
      }
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "sns" {
  count     = var.alarm_email != "" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.securityhub[0].name
  target_id = "securityhub-to-sns"
  arn       = aws_sns_topic.securityhub[0].arn
  input_transformer {
    input_template = "\"SecurityHub <aws_account_id>/<aws_region> <severity> <title> <remediation_url>\""
    input_paths = {
      "aws_account_id"  = "$.detail.findings[0].AwsAccountId"
      "aws_region"      = "$.region"
      "remediation_url" = "$.detail.findings[0].ProductFields.RecommendationUrl"
      "severity"        = "$.detail.findings[0].Severity.Label"
      "title"           = "$.detail.findings[0].Title"
    }
  }
}

resource "aws_cloudformation_stack" "to-email" {
  count         = var.summary_email != "" ? 1 : 0
  name          = "SecurityHubToEmail-${lower(var.project_name)}"
  template_body = file("${path.module}/event-to-email-summury.yaml")
  parameters = {
    AdditionalEmailFooterText           = var.email_footer_text
    SecurityHubRecurringSummarySNSTopic = aws_sns_topic.securityhub-to-email[0].arn
    RecurringScheduleCron               = var.schedule
  }
  capabilities = ["CAPABILITY_IAM"]
}
