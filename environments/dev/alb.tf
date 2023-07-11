module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name                       = "${local.basename}-alb"
  enable_deletion_protection = true
  load_balancer_type         = "application"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  idle_timeout               = 30
  create_security_group      = true
  security_group_name        = "${local.basename}-alb-sg"
  security_group_rules = {
    cloudfront = {
      type            = "ingress"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      description     = "CF web traffic"
      prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
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
  target_groups = [
    {
      name                 = "${local.basename}-admin-tg"
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
        admin = {
          target_id = module.admin.id
          port      = 80
        }
      }
    },
    {
      name                 = "${local.basename}-api-tg"
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
        api = {
          target_id = module.api.id
          port      = 80
        }
      }
    },
    {
      name                 = "${local.basename}-app-tg"
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
        app = {
          target_id = module.app.id
          port      = 80
        }
      }
    },
  ]
  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 1
      actions = [{
        type               = "forward"
        target_group_index = 0
      }]
      conditions = [{
        host_headers = ["develop-admin.${local.project_domain}"]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 2
      actions = [{
        type               = "forward"
        target_group_index = 1
      }]
      conditions = [{
        host_headers = ["develop-api.${local.project_domain}"]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 3
      actions = [{
        type               = "forward"
        target_group_index = 2
      }]
      conditions = [{
        host_headers = ["develop-app.${local.project_domain}"]
      }]
    }
  ]
}
