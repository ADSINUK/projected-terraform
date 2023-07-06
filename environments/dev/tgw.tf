### Transit Gateway: Interconnect project VPCs
module "tgw-attachment" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.10.0"

  create_tgw  = false
  share_tgw   = true
  description = "Connect ${var.project_name} VPCs together"

  name = local.basename
  tags = local.base_tags

  ram_resource_share_arn = data.terraform_remote_state.mgmt.outputs.tgw.share_arn

  vpc_attachments = {
    dev = {
      tgw_id      = data.terraform_remote_state.mgmt.outputs.tgw.id
      vpc_id      = module.vpc.vpc_id
      subnet_ids  = module.vpc.public_subnets
      dns_support = true
    }
  }
}

resource "aws_route" "tgw" {
  for_each               = toset(concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids, module.vpc.database_route_table_ids))
  route_table_id         = each.value
  transit_gateway_id     = data.terraform_remote_state.mgmt.outputs.tgw.id
  destination_cidr_block = "10.0.0.0/8"
}
