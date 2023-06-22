### GuardDuty
module "guardduty" {
  count         = var.install_guardduty ? 1 : 0
  source        = "../../modules/guardduty/base"
  project_name  = var.project_name
  bucket        = "guardduty.${local.aws_region}.${local.project_domain}"
  aws_region    = local.aws_region
  aws_account   = local.aws_account
  name          = local.basename
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = [module.vpc.private_subnets.0]
  log_bucket_id = module.log-bucket[0].bucket.id

  tags = local.base_tags
}

module "guardduty-region" {
  count                             = var.install_guardduty ? 1 : 0
  source                            = "../../modules/guardduty/region"
  aws_region                        = local.aws_region
  aws_account                       = local.aws_account
  guardduty_kms_key                 = module.guardduty[0].kms_key
  bucket                            = module.guardduty[0].bucket
  guardduty_sqs_arn                 = module.guardduty[0].guardduty_sqs_arn
  guardduty_sns_https_subscriptions = var.guardduty_sns_https_subscriptions
  name                              = local.basename

  tags = local.base_tags
}
