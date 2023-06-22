# Subscribe the Acccount to Security Hub
resource "aws_securityhub_account" "this" {}

# Optionally subscribe to Security Hub Standards
resource "aws_securityhub_standards_subscription" "this" {
  for_each = toset(var.standard_subscription_arns)

  depends_on    = [aws_securityhub_account.this]
  standards_arn = each.value
}

# Optionally subscribe to Security Hub Product
resource "aws_securityhub_product_subscription" "this" {
  for_each = toset(var.product_subscription_arns)

  depends_on  = [aws_securityhub_account.this]
  product_arn = each.value
}
