module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases    = aws_acm_certificate.cdn.subject_alternative_names
  web_acl_id = module.waf.web_acl.arn
  viewer_certificate = {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
  origin = {
    "ELB-${split(".", module.alb.lb_dns_name)[0]}" = {
      domain_name = module.alb.lb_dns_name
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "http-only"
        origin_keepalive_timeout = 5
        origin_read_timeout      = 60
        origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }
  default_cache_behavior = {
    target_origin_id         = "ELB-${split(".", module.alb.lb_dns_name)[0]}"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.CachingOptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed-AllViewer.id
    use_forwarded_values     = false
  }
}
