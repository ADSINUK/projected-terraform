resource "random_shuffle" "ovpn_subnet_id" {
  input        = module.vpc.public_subnets
  result_count = 1
}

### OpenVPN-AS instance
module "openvpn" {
  count  = var.install_openvpnas ? 1 : 0
  source = "../../modules/openvpn-as"

  name_prefix = local.basename
  tags        = local.base_tags

  vpc_id    = module.vpc.vpc_id
  subnet_id = random_shuffle.ovpn_subnet_id.result.0

  vpn_routes_cidrs = local.vpn_routes_cidrs

  ### Uncomment this block to enable access with ssh keys
  #allow_ssh = true
  #ssh_key = aws_key_pair.ssh-key.key_name
  #ssh_access_cidrs = ["0.0.0.0/0"]

  ### Enable SSM SSH session logging to Cloudwatch/S3 and enable session encryption with kms
  ### SSM SSH session will not work without this option. log-bucket module must be enabled.
  enable_ssh_logging      = var.install_session_logger ? true : false
  session_logs_bucket_arn = try(module.log-bucket[0].bucket.arn, null)
  ssmkey_arn              = try(module.session-logger[0].kms_key, null)

  # Access from office
  vpn_access_cidrs = ["0.0.0.0/0"]

  # Generate SSL by domain after deploy
  vpn_create_ssl = var.vpn_create_ssl
  project_domain = local.project_domain

  # OpenVPN client profile download
  ovpn_download = var.ovpn_download
}

### Outputs
output "openvpn" {
  value = var.install_openvpnas ? {
    public_ip  = module.openvpn[0].public_ip
    admin_user = module.openvpn[0].admin_user
    admin_pass = module.openvpn[0].admin_pass
    admin_url  = var.vpn_create_ssl ? "https://vpn.${local.project_domain}/admin/" : "https://${module.openvpn[0].public_ip}/admin/"
  } : null
  sensitive = true
}
