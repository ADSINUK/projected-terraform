### Outputs
output "bucket" {
  description = "S3 bucket outputs"
  value = {
    # The name of the bucket.
    id = aws_s3_bucket.this.id
    # The ARN of the bucket. Will be of format arn:aws:s3:::bucketname.
    arn = aws_s3_bucket.this.arn
    # The bucket domain name. Will be of format bucketname.s3.amazonaws.com.
    domain_name = aws_s3_bucket.this.bucket_domain_name
    # The bucket region-specific domain name. The bucket domain name including the region name.
    regional_domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    # The website endpoint, if the bucket is configured with a website. If not, this will be an empty string.
    website_endpoint = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
    # The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string.
    bucket_website_domain = try(aws_s3_bucket_website_configuration.this[0].website_domain, null)
  }
}
