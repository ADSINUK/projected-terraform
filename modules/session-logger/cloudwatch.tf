### Cloudwatch log group for session logs
resource "aws_cloudwatch_log_group" "session-logger" {
  count = var.enable_log_to_cloudwatch ? 1 : 0

  name              = var.cloudwatch_log_group_session_logger
  kms_key_id        = aws_kms_key.session-logger.arn
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = var.cloudwatch_log_group_session_logger
  })
}
