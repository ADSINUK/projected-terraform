### KMS Key
resource "aws_kms_key" "this" {
  description = var.description == "" ? "${var.name} Customer-Managed Key" : var.description

  enable_key_rotation = var.key_rotation

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Id": "1",
      "Statement": [
      %{for svc in var.aws_services}
        {
          "Sid": "Allow key usage via ${upper(svc)} service",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:CreateGrant",
            "kms:DescribeKey"
          ],
          "Resource": "*",
          "Condition": {
            "ForAllValues:StringEquals": {
              "kms:ViaService": [
                "${lower(svc)}.amazonaws.com",
                "${lower(svc)}.${var.aws_region}.amazonaws.com"
              ],
              "kms:CallerAccount": "${var.aws_account}"
            }
          }
        },
      %{endfor}
        {
          "Sid": "Enable IAM User Permissions",
          "Effect": "Allow",
          "Principal": {"AWS": "arn:aws:iam::${var.aws_account}:root"},
          "Action": "kms:*",
          "Resource": "*"
        }
      ]
    }
    EOF

  tags = merge(var.tags, {
    Name = "${var.name}-KEY"
  })
}

# KMS Key Alias
resource "aws_kms_alias" "this" {
  name          = "alias/${replace(var.name, "/[^a-zA-Z0-9/_-]/", "-")}-KEY"
  target_key_id = aws_kms_key.this.key_id
}

# IAM Policy: Allow key usage
resource "aws_iam_policy" "key-usage" {
  name = "${var.name}-KMS-POLICY"
  path = "/"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
          {
            "Effect": "Allow",
            "Action": ["kms:Decrypt", "kms:GenerateDataKey"],
            "Resource": "${aws_kms_key.this.arn}"
          }
      ]
    }
    EOF

  tags = merge(var.tags, {
    Name = "${var.name}-KMS-POLICY"
  })
}
