### Variables
variable "install_cloudtrail" { type = bool }
variable "install_guardduty" { type = bool }
variable "install_securityhub" { type = bool }
variable "install_session_logger" { type = bool }
variable "install_log_bucket" { type = bool }

# GuardDuty topics
variable "guardduty_sns_https_subscriptions" {
  type    = list(any)
  default = [""]
}

### Locals
locals {
  aws_account    = lookup(lookup(var.aws_accounts, var.project_env), "aws_account")
  aws_region     = lookup(lookup(var.aws_accounts, var.project_env), "aws_region")
  vpc_cidr       = lookup(lookup(var.aws_accounts, var.project_env), "vpc_cidr")
  project_domain = lookup(lookup(var.aws_accounts, var.project_env), "project_domain")

  mgmt_vpc_cidr    = lookup(lookup(var.aws_accounts, "MGMT"), "vpc_cidr")
  mgmt_aws_account = lookup(lookup(var.aws_accounts, "MGMT"), "aws_account")
}
