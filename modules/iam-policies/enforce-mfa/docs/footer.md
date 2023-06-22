# Usage example

```terraform
module "iam-enforce-mfa-policy" {
  source = "../../modules/iam-policies/"

  iam_policy_name_prefix = local.basename
}
```
