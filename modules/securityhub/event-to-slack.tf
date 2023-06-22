# Event to slack
resource "aws_cloudformation_stack" "to-slack" {
  count         = var.alarm_slack_endpoint != "" ? 1 : 0
  name          = "SecurityHubToSlack-${lower(var.project_name)}"
  template_body = file("${path.module}/event-to-slack.cf.yaml")
  parameters = {
    IncomingWebHookURL  = var.alarm_slack_endpoint
    SecurityHubEventArn = aws_cloudwatch_event_rule.securityhub[0].arn
  }
  capabilities = ["CAPABILITY_IAM"]
}

resource "aws_cloudwatch_event_target" "to-slack" {
  count     = var.alarm_slack_endpoint != "" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.securityhub[0].name
  target_id = "securityhub-to-slack"
  arn       = aws_cloudformation_stack.to-slack[0].outputs.LambdaFindingsToSlackArn
}
