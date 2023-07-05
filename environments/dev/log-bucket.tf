### Log Bucket
module "log-bucket" {
  count = var.install_log_bucket ? 1 : 0

  source = "../../modules/log-bucket/"

  bucket = lower("dev-logs.${var.project_env}.${local.project_domain}")
}

### Outputs
output "log_bucket" { value = var.install_log_bucket ? module.log-bucket[0].bucket : null }
