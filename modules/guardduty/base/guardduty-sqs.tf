### SQS Queue: Gather SNS alerts from GuardDuty
resource "aws_sqs_queue" "guardduty" {
  name = "${var.name}-GuardDuty-${var.aws_region}"

  kms_master_key_id = aws_kms_alias.guardduty.arn

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Id": "GuardDuty-${var.aws_region}-Policy",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Action": "sqs:SendMessage",
          "Resource": "*",
          "Condition": {
            "ArnLike": {"aws:SourceArn": "arn:aws:sns:*:${var.aws_account}:${var.name}-GuardDuty-*"}
          }
        }
      ]
    }
    POLICY

  tags = merge(var.tags, {
    Name = "${var.name}-GuardDuty-${var.aws_region}"
  })
}

resource "aws_sqs_queue" "guardduty-dlq" {
  name = "${var.name}-GuardDuty-DLQ-${var.aws_region}"

  kms_master_key_id = aws_kms_alias.guardduty.arn

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Id": "GuardDuty-${var.aws_region}-DLQ-Policy",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Action": "sqs:SendMessage",
          "Resource": "*",
          "Condition": {
            "ArnLike": {"aws:SourceArn": "arn:aws:sns:*:${var.aws_account}:${var.name}-GuardDuty-*"}
          }
        }
      ]
    }
    POLICY

  tags = merge(var.tags, {
    Name = "${var.name}-GuardDuty-${var.aws_region}"
  })
}
