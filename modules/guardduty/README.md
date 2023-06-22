# Guardduty module
This module provide complex solution to deploy guardduty over multiple regions.
Block diagram description could be found here:
https://www.lucidchart.com/invitations/accept/d1268c68-f476-41ed-84ff-f5b85676e435

## Problems
The problems of official guardduty implementations:
1. guardduty cannot be enabled over multiple regions with one button.
2. You cannot set publishing destination using terraform. (not yet at least)
3. CloudWatch rule can't send message to SNS subscription in other region. So you have to subscribe your email in every region.

## Sub-modules:

``base`` sub-module
  Covers account-wide CloudTrail setup in the base region. Creates and sets up S3 Bucket for logs
  and findings, a KMS Key for GuardDuty, SQS Queue, SNS Topic for notifications and relaying
  Lambda Function.

``region`` region-specific submodule
  Intended to be invoked in each region. Creates a GuardDuty detector and sets it up to publish
  findings to the central S3 Bucket using the pre-created KMS Key for encryption. Creates SNS
  Topic and subscribes the central SQS Queue to it. Sets up CloudWatch Events Rule and Target to
  route GuardDuty Findings to the SNS Topic.    

## Inputs for base module
|       Name         |      Description           |  Type      | Default | Required |      Example      |
|--------------------|----------------------------|:----------:|:-------:|:--------:|:-----------------:|
| bucket             | name of the s3-bucket      | string     |         | yes      | guardduty-bucket  |
| aws_region         | region for base stuff      | string     |         | yes      | 365               |
| aws_account        | account ID                 | string     |         | yes      |                   |
| project_name       | used by lambda function to |            |         |          |                   |
|                    | add project info to email  |            |         |          |                   |

## Inputs for region module age outputs from base module
|       Name         |      Description           |  Type      | Default | Required |      Example      |
|--------------------|----------------------------|:----------:|:-------:|:--------:|:-----------------:|
| bucket             | map that hold arn of bucket| map(string)|         | yes      | guardduty-bucket  |
| aws_region         | region for detector        | string     |         | yes      | 365               |
| aws_account        | account ID                 | string     |         | yes      |                   |
| guardduty_kms_key  | map that hold arn of KMS   | map(string)|         | yes      |                   |
| guardduty_sqs_arn  | ARN of sqs queue           | string     |         | yes      |                   |


## Output
|        Name       | Description |  Type  |
|-------------------|-------------|:------:|
| kms_key           | kms arn     | map    |
| bucket            | Bucket      | map    |
| guardduty_sns     | SNS Topic   | map    |
| guardduty_sqs_arn | SQS Queue   | string |



## Example
```

module "guardduty" {
  source             = "../../modules/guardduty/base"
  bucket = "guardduty.${var.aws_region}.${var.project_domain}"
  aws_region = var.aws_region
  aws_account = var.aws_account
  project_name = var.project_name
  tags = local.base_tags
}

module "guardduty-us-east-1" {
  source = "../../modules/guardduty/region"
  aws_region = "us-east-1"
  aws_account = var.aws_account
  guardduty_kms_key = module.guardduty.kms_key
  bucket = module.guardduty.bucket
  guardduty_sqs_arn = module.guardduty.guardduty_sqs_arn
}

module "guardduty-eu-west-1" {
  source = "../../modules/guardduty/region"
  aws_region = "eu-west-1"
  aws_account = var.aws_account
  guardduty_kms_key = module.guardduty.kms_key
  bucket = module.guardduty.bucket
  guardduty_sqs_arn = module.guardduty.guardduty_sqs_arn
}

```
