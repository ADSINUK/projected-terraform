### Providers
terraform {
  required_providers {
    aws = {
      version = ">= 4.35.0"
    }
  }
}

### Blacklist
resource "aws_wafv2_ip_set" "blacklisted-ips" {
  name               = "${var.name}-Match-Deny-IPs"
  scope              = var.scope
  ip_address_version = var.ip_address_version

  addresses = var.blacklisted_ips

  tags = merge(var.tags, {
    Name = "${var.name}-Fortinet-OWASP-Deny-IP"
  })
}

### Whitelist
resource "aws_wafv2_ip_set" "whitelisted-ips" {
  name               = "${var.name}-Match-Allow-IPs"
  scope              = var.scope
  ip_address_version = var.ip_address_version

  addresses = var.whitelisted_ips

  tags = merge(var.tags, {
    Name = "${var.name}-Fortinet-OWASP-Allow-IP"
  })
}

### WAF
resource "aws_wafv2_web_acl" "waf-acl" {
  name  = "${var.name}-Fortinet-OWASP-Webv2ACL"
  scope = var.scope

  default_action {
    allow {}
  }

  rule {
    name     = "whitelist"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelisted-ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allow-list-metric-name"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "blacklist"
    priority = 2

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklisted-ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-list-metric-name"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Fortinet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "all_rules"
        vendor_name = "Fortinet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "fortinet-metric-name"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "fortinet-waf2-metric-name"
    sampled_requests_enabled   = true
  }

  tags = merge(var.tags, {
    Name = "${var.name}-Fortinet-OWASP-Webv2ACL"
  })
}

### Logging
module "logging" {
  count  = var.enable_logging ? 1 : 0
  source = "./logging/"

  name           = var.name
  waf_acl_arn    = aws_wafv2_web_acl.waf-acl.arn
  log_bucket_arn = var.log_bucket_arn

  tags = var.tags
}

# vim:filetype=terraform ts=2 sw=2 et:
