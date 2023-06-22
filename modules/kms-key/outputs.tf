### Outputs
output "key" {
  value = {
    id    = aws_kms_key.this.id
    arn   = aws_kms_key.this.arn
    alias = aws_kms_alias.this.id
  }
  description = "An output with the Key ID, Key ARN, and Alias."
}
output "usage_policy" {
  value = {
    arn  = aws_iam_policy.key-usage.arn
    name = aws_iam_policy.key-usage.name
  }
  description = "An output with IAM policy ARN and IAM policy Name for the KMS Key."
}
