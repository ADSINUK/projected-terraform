### Common variables
# Account info
variable "aws_accounts" { type = map(map(string)) }

# Terraform state S3 bucket and DynamoDB table (e.g., for remote_state)
variable "tfstate_region" { type = string }
variable "tfstate_bucket" { type = string }

# Project identification
variable "project_env" { type = string }
variable "project_name" { type = string }

# Network params
variable "vpc_flowlogs_enable" {
  type    = bool
  default = false
}

variable "total_azs" {
  type    = number
  default = 3
}

/*
  Access variables for CIDRs and for Security groups.

  All AIT modules have unified access_cidrs and access_sgs.
  The idea of these parameters is to put into modules some additional CIRs or SGs which should
  have access to the module resources.
  Each module should use own logic to which resources and how to provide access.
  We need these parameters for example to provide access for prod env resources from management VPC, etc.
  An example of the param:
  access_cidrs = {"MGMT" = "10.200.0.0/16"}
*/
variable "access_cidrs" {
  type    = map(any)
  default = {}
}
variable "access_sgs" {
  type    = map(any)
  default = {}
}

# Monitoring parameters
variable "monitoring_enable_key" {
  default = "EnableMonitoring"
  type    = string
}
variable "monitoring_autoalert_key_prefix" {
  default = "AutoAlarms"
  type    = string
}

# Region restriction, enforce MFA for the members in these group
variable "iam_group_name" {
  default = []
  type    = list(string)
}

### Handy locals
locals {
  # Base name prefix
  basename = "${var.project_name}-${var.project_env}"

  # Base resource-independent tags. Left here for the back compatibility
  base_tags = {
  }
  # Base resource-independent tags
  provider_base_tags = {
    Project     = var.project_name
    Environment = var.project_env
    Managed_by  = "terraform"
    Name        = ""
  }
}
