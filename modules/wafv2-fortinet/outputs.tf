### Outputs
output "web_acl" {
  description = "WEB ACL outputs"
  value = {
    id  = aws_wafv2_web_acl.waf-acl.id
    arn = aws_wafv2_web_acl.waf-acl.arn
  }
}

# vim:filetype=terraform ts=2 sw=2 et:
