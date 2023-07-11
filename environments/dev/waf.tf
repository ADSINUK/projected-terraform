module "waf" {
  source    = "../../modules/wafv2-fortinet"
  providers = { aws = aws.us-east-1 }

  name            = local.basename
  scope           = "CLOUDFRONT"
  log_bucket_arn  = module.log-bucket[0].bucket.arn
  blacklisted_ips = []
}
