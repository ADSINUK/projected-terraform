### Variables
variable "project_name" {
  description = "project name"
  type        = string
}
variable "severity_list" {
  description = "Findings across integrated products to prioritize the most important ones."
  type        = list(any)
  default     = ["HIGH", "CRITICAL"]
}
variable "standard_subscription_arns" {
  description = "List of standards/rulesets to enable. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription#argument-reference"
  type        = list(any)
  default     = ["arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"]
}
variable "product_subscription_arns" {
  description = "List of product arns to subscribe to. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_product_subscription"
  type        = list(string)
  default     = []
}
variable "sns_name" {
  description = "Name to be used on all resources as prefix"
  default     = "detect-securityhub-finding"
  type        = string
}
variable "alarm_email" {
  type        = string
  default     = ""
  description = "Enables email notification (optional)"
}
variable "summary_email" {
  type        = string
  default     = ""
  description = "Enables a recurring Security Hub summary email (optional)"
}
variable "alarm_slack_endpoint" {
  type        = string
  default     = ""
  description = "Enables slack notification to endpoint passed (optional)"
}
variable "schedule" {
  type        = string
  default     = "cron(0 8 ? * 2 *)"
  description = "Cron expression for scheduling the Security Hub summary email. Default: Every Monday 8:00 AM GMT. Example: Every Friday 9:00 AM GMT: cron(0 9 ? * 6 *)"
}
variable "email_footer_text" {
  type        = string
  default     = ""
  description = "Additional text to append at the end of email message."
}
