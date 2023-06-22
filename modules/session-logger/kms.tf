### KMS Key: CloudWatch log group and SSM sessions
resource "aws_kms_key" "session-logger" {
  description = "Key for CloudWatch Logs to use the key"

  enable_key_rotation = var.kms_key_rotation

  # Allow key usage by CloudWatch log group and account users
  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
              "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
          },
          "Action": [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "kms:*",
          "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
          "Resource": "*"
        }
      ]
  }
  EOF

  tags = merge(var.tags, {
    Name = var.name
  })
}

# KMS Key: Alias
resource "aws_kms_alias" "session-logger" {
  name          = "alias/session-logger"
  target_key_id = aws_kms_key.session-logger.id
}
