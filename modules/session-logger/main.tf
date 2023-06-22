### Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### SSM document for Session Manager
resource "aws_ssm_document" "session-manager-document" {
  name            = var.ssm_document_session_name
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document that contains regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = var.enable_log_to_s3 ? var.bucket_name : ""
      s3EncryptionEnabled         = var.enable_log_to_s3 ? "true" : "false"
      s3KeyPrefix                 = var.enable_log_to_s3 ? var.bucket_prefix : ""
      cloudWatchLogGroupName      = var.enable_log_to_cloudwatch ? aws_cloudwatch_log_group.session-logger[0].name : ""
      cloudWatchEncryptionEnabled = var.enable_log_to_cloudwatch ? "true" : "false"
      kmsKeyId                    = aws_kms_key.session-logger.key_id
      shellProfile = {
        linux   = var.linux_shell_profile == "" ? var.linux_shell_profile : ""
        windows = var.windows_shell_profile == "" ? var.windows_shell_profile : ""
      }
    }
  })

  tags = merge(var.tags, {
    Name = var.name
  })
}
