### Outputs
output "iam_policy_arn" {
  description = "Enforce MFA IAM policy ARN"
  value       = aws_iam_policy.iam-enforce-mfa-policy.arn
}
