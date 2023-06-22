### Outputs
output "bucket" {
  description = "Bucket destination where GuardDuty exports active findings"
  value = {
    name   = var.bucket
    arn    = module.s3-guardduty.bucket.arn
    region = var.aws_region
  }
}
output "kms_key" {
  description = "KMS key that GuardDuty uses to encrypt findings"
  value = {
    name = aws_kms_alias.guardduty.name
    id   = aws_kms_key.guardduty.key_id
    arn  = aws_kms_key.guardduty.arn
  }
}
output "guardduty_sqs_arn" {
  description = "GuardDuty SQS queue"
  value       = aws_sqs_queue.guardduty.arn
}
output "guardduty_sns" {
  description = "GuardDuty SNS topic"
  value       = aws_sns_topic.guardduty.arn
}
