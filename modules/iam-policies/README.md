<!-- BEGIN_TF_DOCS -->
# IAM policy to enforce MFA

Terraform module to create IAM policy that enforces user to setup MFA.

What does this policy do?
* `AllowViewAccountInfo`: allows the user to view details about a virtual MFA device that is enabled for the user.
* `AllowManageOwnVirtualMFADevice`: allows the user to create and delete their own virtual MFA device.
* `AllowManageOwnUserMFA`: allows the user to view or manage their own virtual, U2F, or hardware MFA device.
* `DenyAllExceptListedIfNoMFA`: denies access to every action in all AWS services, except a few listed actions, but only if the user is not signed in with MFA.

This policy should be treated as a baseline according to AWS well-architected recommendations. If an IAM user with this policy is not MFA-authenticated, this policy denies access to all AWS actions except those necessary to authenticate using MFA.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.iam-enforce-mfa-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| iam_policy_name_prefix | IAM policy name prefix. Will be appended with `-iam-enforce-mfa-policy` | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| iam_policy_arn | Enforce MFA IAM policy ARN |

# Usage example

```terraform
module "iam-enforce-mfa-policy" {
  source = "../../modules/iam/"

  iam_policy_name_prefix = local.basename
}
```
<!-- END_TF_DOCS -->