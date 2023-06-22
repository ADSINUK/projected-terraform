### VPC: MGMT
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = local.basename
  cidr = local.vpc_cidr

  azs              = local.zone_ids
  public_subnets   = [for k, v in local.zone_ids : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnets  = [for k, v in local.zone_ids : cidrsubnet(local.vpc_cidr, 4, k + 4)]
  database_subnets = [for k, v in local.zone_ids : cidrsubnet(local.vpc_cidr, 4, k + 8)]

  create_database_subnet_route_table = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags  = { Tier = "Public" }
  private_subnet_tags = { Tier = "Private" }
}

## Outputs
output "vpc" {
  value = {
    id   = module.vpc.vpc_id
    name = module.vpc.name
    cidr = local.vpc_cidr

    rt_default = module.vpc.default_route_table_id
    rt_public  = module.vpc.public_route_table_ids
    rt_private = module.vpc.private_route_table_ids
  }
}
