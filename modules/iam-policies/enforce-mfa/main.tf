### IAM: Enforce MFA policy
resource "aws_iam_policy" "iam-enforce-mfa-policy" {
  name        = "${var.iam_policy_name_prefix}-iam-enforce-mfa-policy"
  path        = "/"
  description = "IAM policy that enforces users to enable MFA"
  tags        = { Name = "${var.iam_policy_name_prefix}-iam-enforce-mfa-policy" }
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_group_policy_attachment" "to-groups" {
  for_each = {
    for k in var.groups : k => k
    if var.groups != ""
  }

  group      = each.value
  policy_arn = aws_iam_policy.iam-enforce-mfa-policy.arn
}
