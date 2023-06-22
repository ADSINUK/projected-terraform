# MODULE: KMS Customer-Managed Key

## General

This module creates a customer-managed key and key alias at Amazon KMS,
and configures key policy to allow key usage by specific Amazon
Services. Also an IAM Policy is created to allow key usage to IAM users
and roles.

## Parameters

* `name`, `tags`

	Base name of the key and tags to add to it

* `aws_account`, `aws_region`

	AWS Account Number and region name to use in the policies

* `aws_services`

	A list of AWS services allowed to use the key, empty by default
    (only explicit IAM permissions are used)

* `description`

	(Optional) description for the KMS Key

## Outputs

* `key`

	Map containing values for `id` (key UUID), `arn` (full ARN), and
    `alias` (alias ARN)

* `usage_policy`

	Map containing values for `name` and `arn` of the IAM Policy

## Usage notes

Preferred way to use the KMS keys created by this module is through
other Amazon services: key policy implicitly grants usage rights to the
specified services using `kms::ViaService` policy condition.

This passes the access control to the specific service: if, e.g., an
instance has access to a specific S3 Bucket encrypted with the key it
also has access to the key itself, so no extra IAM permissions are
necessary. However using the `kms:ViaService` condition key ensures that
principal has no direct access to the key: e.g., though they can read
and decrypt an object from the bucket they cannot call DescribeKey or
other KMS actions directly.

Using the key with Amazon EC2 Auto Scaling requires that both \"ec2\"
and \"autoscaling\" are added to `aws_services` list - otherwise Auto
Scaling would fail to launch the instance because it lacks access to the
key.

## Example

The module can be used as follows:

```
### KMS Key for EC2 and AutoScaling
data "aws_caller_identity" "kms-example" {}
data "aws_region" "kms-example" {}
module "kms-example" {
  source = "../../modules/kms-key/"

  name = "${local.basename}-EC2-example"
  tags = local.base_tags

  aws_services = ["autoscaling", "ec2"]
  aws_account = data.aws_caller_identity.kms-example.account_id
  aws_region  = data.aws_region.kms-example.name
}

### Outputs
output "kms-example-key"    { value = module.kms-example.key }
output "kms-example-policy" { value = module.kms-example.usage_policy }
```

--
Copyright (c) 2023 Automat-IT
