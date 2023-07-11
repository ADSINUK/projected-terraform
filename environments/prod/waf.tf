module "waf" {
  source    = "../../modules/wafv2-fortinet"
  providers = { aws = aws.us-east-1 }

  name           = local.basename
  scope          = "CLOUDFRONT"
  log_bucket_arn = data.terraform_remote_state.mgmt.outputs.log_bucket.arn
}
