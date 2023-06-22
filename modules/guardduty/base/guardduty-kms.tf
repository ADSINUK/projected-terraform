### KMS Key: GuardDuty
resource "aws_kms_key" "guardduty" {
  description         = "Key for GuardDuty findings encryption"
  enable_key_rotation = true

  # Allow key usage by GuardDuty and account users
  policy = <<-EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "guardduty.amazonaws.com"
            },
            "Action": "kms:GenerateDataKey",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CWE to use the key",
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow Amazon SNS to use this key",
            "Effect": "Allow",
            "Principal": {
                "Service": "sns.amazonaws.com"
            },
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow Amazon SQS to use this key",
            "Effect": "Allow",
            "Principal": {
                "Service": "sqs.amazonaws.com"
            },
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": "*"
        }
    ]
}
    EOF
}

# User-friendly key alias
resource "aws_kms_alias" "guardduty" {
  name          = "alias/guardduty-${var.aws_region}"
  target_key_id = aws_kms_key.guardduty.id
}

#This key used by CloudWatch logs
resource "aws_kms_key" "guard-cloudwatch" {
  description         = "Key for GuardDuty findings encryption"
  enable_key_rotation = true
  policy              = <<-EOF
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${var.aws_region}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.aws_region}:${var.aws_account}:*"
                }
            }
        }    
    ]
}
  EOF
}

# User-friendly key alias
resource "aws_kms_alias" "cloudwatch-kms" {
  name          = "alias/guard-logs-${var.aws_region}"
  target_key_id = aws_kms_key.guard-cloudwatch.id
}


resource "aws_kms_key" "kms-lambda" {
  description         = "Key for legacy microservice secret encryption/decryption"
  enable_key_rotation = true
  is_enabled          = true
  policy              = <<-EOF
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
    "Resource": "arn:aws:kms:${var.aws_region}:${var.aws_account}:*",
    "Condition": {
      "StringEquals": {
        "kms:EncryptionContext:LambdaFunctionName": "${var.name}-guardduty-findings-relay"
      }
    }
  } ]
}
  EOF
}

resource "aws_kms_alias" "lambda-kms-alias" {
  name          = "alias/lambda-${var.aws_region}"
  target_key_id = aws_kms_key.kms-lambda.key_id
}
