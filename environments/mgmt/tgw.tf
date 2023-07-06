### Transit Gateway: Interconnect project VPCs
module "transit-gateway" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.10.0"

  description = "Connect ${var.project_name} VPCs together"

  name = local.basename
  tags = local.base_tags

  enable_auto_accept_shared_attachments = true
  vpc_attachments = {
    mgmt = {
      vpc_id      = module.vpc.vpc_id
      subnet_ids  = module.vpc.public_subnets
      dns_support = true

      vpc_route_table_ids  = concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids)
      tgw_destination_cidr = "10.0.0.0/8"
    }
  }
  share_tgw                     = true
  ram_allow_external_principals = true
  ram_principals                = [local.dev_aws_account]
}

## Outputs
output "tgw" {
  value = {
    id        = module.transit-gateway.ec2_transit_gateway_id
    rt_id     = module.transit-gateway.ec2_transit_gateway_route_table_id
    arn       = module.transit-gateway.ec2_transit_gateway_arn
    share_arn = module.transit-gateway.ram_resource_share_id
  }
}
