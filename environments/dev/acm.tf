resource "aws_acm_certificate" "dev" {
  domain_name = "develop.${local.project_domain}"
  subject_alternative_names = [
    "develop-admin.${local.project_domain}",
    "develop-api.${local.project_domain}",
    "develop-app.${local.project_domain}",
  ]
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.dev.arn
}

output "acm" {
  value = {
    validation = aws_acm_certificate.dev.domain_validation_options
  }
}

resource "aws_acm_certificate" "cdn" {
  provider    = aws.us-east-1
  domain_name = "develop.${local.project_domain}"
  subject_alternative_names = [
    "develop-admin.${local.project_domain}",
    "develop-api.${local.project_domain}",
    "develop-app.${local.project_domain}",
  ]
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_acm_certificate_validation" "cdn" {
  provider        = aws.us-east-1
  certificate_arn = aws_acm_certificate.cdn.arn
}
