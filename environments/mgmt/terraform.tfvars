### Environment-specific options
project_env = "MGMT"

# Security
install_cloudtrail     = true
install_guardduty      = true
install_securityhub    = true
install_openvpnas      = true
install_session_logger = true
install_log_bucket     = true

# OpenVPN-AS
# WARNING: define CIDR for all non-MGMT environments (see "vpc_cidr" variable at each environment)
vpn_create_ssl = false
ovpn_download  = true

# GuardDuty SNS endpoint
guardduty_sns_https_subscriptions = ["https://events.pagerduty.com/integration/4930ee4b856f4a06d060f7bae9a16a01/enqueue"]
