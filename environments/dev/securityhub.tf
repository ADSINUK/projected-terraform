### Security Hub
module "securityhub" {
  count = var.install_securityhub ? 1 : 0

  source       = "../../modules/securityhub"
  project_name = var.project_name
}
