resource "aws_acm_certificate" "cdn" {
  provider                  = aws.us-east-1
  domain_name               = local.project_domain
  subject_alternative_names = ["*.${local.project_domain}"]
  validation_method         = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_acm_certificate_validation" "cdn" {
  provider        = aws.us-east-1
  certificate_arn = aws_acm_certificate.cdn.arn
}
