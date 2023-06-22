# MODULE: Security Hub

## General

This module sets up Security Hub in an account with option to send
findings to slack and/or email.

The following resources will be created:

SecurityHub Lambda function to send slack notifications (created using
cloudformation, based on
<https://github.com/aws-samples/aws-securityhub-to-slack>). EventBridge
Rules SNS topics

## `securityhub` module

### Parameters

* `alarm_email` - Enables email notification (optional).

* `alarm_slack_endpoint` - Enables slack notification to endpoint passed (optional).

* `standard_subscription_arns` - Enables PCI-DSS Standards subscription.

* `product_subscription_arns` - Subscribes to a Security Hub product.

* `sns_name` - Name to be used on all resources as prefix.

* `alarm_email` - Enables email notification (optional).
* `summary_email` - Enables a recurring Security Hub summary email (optional).
* `alarm_slack_endpoint` - Enables slack notification to endpoint passed (optional)
* `schedule` - Cron expression for scheduling the Security Hub summary email.
Default: Every Monday 8:00 AM GMT. 
Example: Every Friday 9:00 AM GMT: `cron(0 9 ? \* 6 \*)`
* `email_footer_text` - Additional text to append at the end of email message.

### Example

Is an example of using this module:

```
### Security Hub
module "securityhub" {
  count = var.install_securityhub ? 1 : 0

  source       = "../../modules/securityhub"
  project_name = var.project_name
}
```
--
Copyright (c) 2022 Automat-IT
