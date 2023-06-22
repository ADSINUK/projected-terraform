### IAM: Enforce MFA
module "iam-enforce-mfa-policy" {
  source = "../../modules/iam-policies/enforce-mfa"

  iam_policy_name_prefix = local.basename
  groups                 = var.iam_group_name
}
