### Variables
variable "install_cloudtrail" { type = bool }
variable "install_guardduty" { type = bool }
variable "install_openvpnas" { type = bool }
variable "install_securityhub" { type = bool }
variable "install_session_logger" { type = bool }
variable "install_log_bucket" { type = bool }

variable "vpn_create_ssl" { type = bool }
variable "ovpn_download" { type = bool }

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

  prod_vpc_cidr   = lookup(lookup(var.aws_accounts, "PROD"), "vpc_cidr")
  dev_vpc_cidr    = lookup(lookup(var.aws_accounts, "DEV"), "vpc_cidr")
  dev_aws_account = lookup(lookup(var.aws_accounts, "DEV"), "aws_account")
  # CIDR list for OpenVPN
  vpn_routes_cidrs = [local.prod_vpc_cidr, local.dev_vpc_cidr]
}
