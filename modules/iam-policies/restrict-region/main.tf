### IAM: Region restriction policy
resource "aws_iam_policy" "region-restriction-policy" {
  name        = "${var.iam_policy_name_prefix}-region-restriction-policy"
  path        = "/"
  description = "IAM policy that enforces users to restriction region"
  tags        = { Name = "${var.iam_policy_name_prefix}-region-restriction-policy" }
  policy      = data.aws_iam_policy_document.region-restriction-policy.json
}

resource "aws_iam_group_policy_attachment" "groups" {
  for_each = {
    for k in var.groups : k => k
    if var.groups != ""
  }

  group      = each.value
  policy_arn = aws_iam_policy.region-restriction-policy.arn
}
