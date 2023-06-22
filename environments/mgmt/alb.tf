module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name                       = "${local.basename}-alb"
  enable_deletion_protection = true
  internal                   = true
  load_balancer_type         = "application"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.private_subnets
  idle_timeout               = 30
  create_security_group      = true
  security_group_name        = "${local.basename}-alb-sg"
  security_group_rules = {
    ingress_https_ovpn = {
      type                     = "ingress"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "HTTPS web traffic"
      source_security_group_id = module.openvpn[0].sg
    }
    ingress_http_ovpn = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "HTTP web traffic"
      source_security_group_id = module.openvpn[0].sg
    }
    egress_vpc = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [local.vpc_cidr]
    }
  }

  http_tcp_listeners = [{
    port        = 80
    protocol    = "HTTP"
    action_type = "fixed-response"
    fixed_response = {
      content_type = "text/plain"
      status_code  = "404"
    }
  }]
  https_listeners = [{
    port               = 443
    protocol           = "HTTPS"
    target_group_index = 0
    certificate_arn    = aws_acm_certificate.wildcard.arn
    ssl_policy         = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    action_type        = "fixed-response"
    fixed_response = {
      content_type = "text/plain"
      status_code  = "404"
    }
  }]
  target_groups = [
    {
      name                 = "${local.basename}-octopus-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 5
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-499"
      }
      targets = {
        octopus = {
          target_id = module.octopus.id
          port      = 80
        }
      }
    },
    {
      name                 = "${local.basename}-teamcity-tg"
      backend_protocol     = "HTTP"
      backend_port         = 4444
      target_type          = "instance"
      deregistration_delay = 5
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-499"
      }
      targets = {
        teamcity = {
          target_id = module.teamcity.id
          port      = 4444
        }
      }
    }
  ]
  http_tcp_listener_rules = [{
    http_tcp_listener_index = 0
    priority                = 1
    actions = [{
      type        = "redirect"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }]
    conditions = [{
      host_headers = ["*.${aws_acm_certificate.wildcard.domain_name}"]
    }]
  }]
  https_listener_rules = [
    {
      https_listener_index = 0
      priority             = 1
      actions = [{
        type               = "forward"
        target_group_index = 0
      }]
      conditions = [{
        host_headers = ["octopus.${aws_acm_certificate.wildcard.domain_name}"]
      }]
    },
    {
      https_listener_index = 0
      priority             = 2
      actions = [{
        type               = "forward"
        target_group_index = 1
      }]
      conditions = [{
        host_headers = ["teamcity.${aws_acm_certificate.wildcard.domain_name}"]
      }]
    }
  ]
}
