### Outputs
output "iam_policy_arn" {
  description = "Restriction region IAM policy ARN"
  value       = aws_iam_policy.region-restriction-policy.arn
}
