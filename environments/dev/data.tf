### Data sources
# MGMT State
data "terraform_remote_state" "mgmt" {
  backend = "s3"
  config = {
    profile = "projectedai-prod-admin"
    region  = var.tfstate_region
    bucket  = var.tfstate_bucket
    key     = "environments/mgmt/terraform.tfstate"
  }
}
# Availability zones
data "aws_availability_zones" "aws-azs" {}

data "aws_ami" "admin" {
  most_recent = true
  owners      = [local.aws_account]
  filter {
    name   = "name"
    values = ["dev-admin"]
  }
}
data "aws_ami" "api" {
  most_recent = true
  owners      = [local.aws_account]
  filter {
    name   = "name"
    values = ["dev-api"]
  }
}
data "aws_ami" "app" {
  most_recent = true
  owners      = [local.aws_account]
  filter {
    name   = "name"
    values = ["dev-app"]
  }
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "Managed-AllViewer" {
  name = "Managed-AllViewer"
}

### Handy locals
locals {
  zone_names = slice(data.aws_availability_zones.aws-azs.names, 0, var.total_azs)
  zone_ids   = slice(data.aws_availability_zones.aws-azs.zone_ids, 0, var.total_azs)
}

### Outputs
# Pass some common values to all other environments to speed up refresh stage
output "zone_names" { value = local.zone_names }
output "zone_ids" { value = local.zone_ids }
