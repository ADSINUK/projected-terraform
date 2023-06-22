resource "aws_acm_certificate" "wildcard" {
  domain_name               = local.project_domain
  subject_alternative_names = ["*.${local.project_domain}"]
  validation_method         = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.wildcard.arn
}

output "acm" {
  value = {
    certificate_arn = aws_acm_certificate.wildcard.arn
    validation      = aws_acm_certificate.wildcard.domain_validation_options
  }
}
