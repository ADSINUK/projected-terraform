### Outputs
output "bucket" {
  description = "S3 log bucket information"
  value = {
    # The name of the bucket.
    id = aws_s3_bucket.this.id
    # The name of the bucket.
    name = aws_s3_bucket.this.id
    # The ARN of the bucket. Will be of format arn:aws:s3:::bucketname.
    arn = aws_s3_bucket.this.arn
  }
}
