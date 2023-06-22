### Binary compatibility settings
### Terraform/Terragrunt Version Mapping
### https://terragrunt.gruntwork.io/docs/getting-started/supported-terraform-versions/
    # 1.4.x   >= 0.45.0
    # 1.3.x   >= 0.40.0
    # 1.2.x   >= 0.38.0
    # 1.1.x   >= 0.36.0
    # 1.0.x   >= 0.31.0
terraform_version_constraint = ">= 1.4"
terragrunt_version_constraint = ">= 0.45"

### Project identification
locals {
  project_name = "projected-ai"

  # CloudTrail, SecurityHub, Session Logger, IAM Access Analyzer, GuardDuty are global services, requires one installation per account
  aws_accounts = {
    MGMT = {
      aws_account                 = "604692217986"
      aws_region                  = "eu-west-2"
      vpc_cidr                    = "10.0.0.0/16"
      project_domain              = "projected.ai"
    }
    DEV = {
      aws_account                 = "511546041908"
      aws_region                  = "eu-west-2"
      vpc_cidr                    = "10.10.0.0/16"
      project_domain              = "projected.ai"
    }
    PROD = {
      aws_account                 = "604692217986"
      aws_region                  = "eu-west-2"
      vpc_cidr                    = "10.20.0.0/16"
      project_domain              = "projected.ai"
    }
  }

  tfstate_region = lookup(lookup(local.aws_accounts, "MGMT"), "aws_region")
  tfstate_bucket = lower("tfstate.${local.tfstate_region}.${lookup(lookup(local.aws_accounts, "MGMT"), "project_domain")}")
}

### Automatic input variables
inputs = {
  # Must be overriden in environments
  project_env    = ""

  # Same for all environments
  aws_accounts   = local.aws_accounts
  project_name   = local.project_name

  # State parameters
  tfstate_region = local.tfstate_region
  tfstate_bucket = local.tfstate_bucket
}

### Terraform configuration
terraform {
  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = [
      "${get_parent_terragrunt_dir()}/common.tfvars",
    ]

    # Ensure that terraform.tfvars is loaded *after* common.tfvars
    optional_var_files = [
      "${get_terragrunt_dir()}/terraform.tfvars",
    ]
  }
}

### Remote state S3 configuration
remote_state {
  backend = "s3"
  config = {
    profile = "projectedai-prod-admin"
    region  = local.tfstate_region
    bucket  = local.tfstate_bucket
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
  }
}
