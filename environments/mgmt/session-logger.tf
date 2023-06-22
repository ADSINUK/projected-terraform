### AWS Systems Manager Session Manager
# It's a global module in the account
module "session-logger" {
  count = var.install_session_logger ? 1 : 0

  source = "../../modules/session-logger"

  bucket_name              = var.install_log_bucket ? module.log-bucket[0].bucket.name : ""
  name                     = local.basename
  tags                     = local.base_tags
  enable_log_to_cloudwatch = true
  enable_log_to_s3         = true
}

### Outputs
output "kms_key" {
  value = var.install_session_logger ? module.session-logger[0].kms_key : null
}
