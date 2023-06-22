### SNS Topic: GuardDuty notifications
resource "aws_sns_topic" "guardduty" {
  # GuardDuty is not project-specific
  name              = "${var.name}-GuardDuty-Notifies-${var.aws_region}"
  kms_master_key_id = aws_kms_alias.guardduty.arn

  tags = merge(var.tags, {
    Name = "${var.name}-GuardDuty-Notifies-${var.aws_region}"
  })
}
