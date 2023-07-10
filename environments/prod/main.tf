### General blurb
terraform {
  backend "s3" {}
  required_providers {
    aws = "~> 4.0"
  }
}

provider "aws" {
  region  = local.aws_region
  profile = "projectedai-prod-admin"

  # Default tags to be set for all the resources created by the AWS provider
  default_tags {
    tags = local.provider_base_tags
  }

  # Tags for the monitoring solution
  ignore_tags {
    keys         = [var.monitoring_enable_key, "Creator"]
    key_prefixes = [var.monitoring_autoalert_key_prefix]
  }
}

# AWS Provider for CloudFront, WAF, ACM, etc
provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "projectedai-prod-admin"

  default_tags {
    tags = local.provider_base_tags
  }

  # Tags for the monitoring solution
  ignore_tags {
    keys         = [var.monitoring_enable_key, "Creator"]
    key_prefixes = [var.monitoring_autoalert_key_prefix]
  }
}
