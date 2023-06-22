### Outputs
output "guardduty_sns" {
  description = "GuardDuty SNS topic"
  value       = aws_sns_topic.guardduty.arn
}
