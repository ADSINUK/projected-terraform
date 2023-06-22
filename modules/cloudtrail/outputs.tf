### Outputs
output "bucket" {
  description = "S3 bucket for CloudTrail logs"
  value = {
    # CloudTrail S3 ARN
    arn = module.s3-cloudtrail.bucket.arn
  }
}
