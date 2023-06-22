### AIM Access Analyzer
module "iam-access-analyzer" {
  source = "../../modules/iam-access-analyzer"
  tags   = local.base_tags

  analyzer_name = "${local.basename}-Access-Analyzer"
}
