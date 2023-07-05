### Multi-regional CloudTrail
module "cloudtrail" {
  count = var.install_cloudtrail ? 1 : 0

  source = "../../modules/cloudtrail"

  aws_account = local.aws_account
  aws_region  = local.aws_region
  basename    = "${local.basename}-CloudTrail"
  bucket      = "dev-cloudtrail.${local.aws_region}.${local.project_domain}"

  tags = local.base_tags
}
