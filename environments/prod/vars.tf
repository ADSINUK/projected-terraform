### Locals
locals {
  aws_account    = lookup(lookup(var.aws_accounts, var.project_env), "aws_account")
  aws_region     = lookup(lookup(var.aws_accounts, var.project_env), "aws_region")
  vpc_cidr       = lookup(lookup(var.aws_accounts, var.project_env), "vpc_cidr")
  project_domain = lookup(lookup(var.aws_accounts, var.project_env), "project_domain")

  mgmt_vpc_cidr = lookup(lookup(var.aws_accounts, "MGMT"), "vpc_cidr")
}
