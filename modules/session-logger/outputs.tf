### Outputs
output "kms_key" {
  description = "KMS key ARN for session logger"
  value       = aws_kms_key.session-logger.arn
}
