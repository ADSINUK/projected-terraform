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

### Handy locals
locals {
  zone_names = slice(data.aws_availability_zones.aws-azs.names, 0, var.total_azs)
  zone_ids   = slice(data.aws_availability_zones.aws-azs.zone_ids, 0, var.total_azs)
}

### Outputs
# Pass some common values to all other environments to speed up refresh stage
output "zone_names" { value = local.zone_names }
output "zone_ids" { value = local.zone_ids }
