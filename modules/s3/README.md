<!-- BEGIN_TF_DOCS -->
# S3 module

## General

This module describes S3 bucket.

Copyright (c) 2023 Automat-IT

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.s3-replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.s3-replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_alias.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.ownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.allow-website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny-insecure-transport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the bucket. If omitted. | `string` | n/a | yes |
| acl | The canned ACL to apply. Defaults to 'private' | `string` | `"private"` | no |
| attach_policy | Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy) | `bool` | `false` | no |
| attach_policy_website | A boolean, that enable static web-site hosting. | `bool` | `false` | no |
| block_public_acls | Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `true` | no |
| block_public_policy | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `true` | no |
| cors_rule | List of maps containing rules for Cross-Origin Resource Sharing. | `any` | `[]` | no |
| deny_insecure_transport | Controls if S3 bucket should have deny non-SSL transport policy attached. | `bool` | `false` | no |
| enable_cors | A boolean, that enable cors. | `bool` | `false` | no |
| enable_encryption | Whether Amazon S3 should enable server-side encryption for this bucket. | `bool` | `true` | no |
| enable_versioning | A boolean, that enable versioning. | `bool` | `false` | no |
| force_destroy | (Optional) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `true` | no |
| ignore_public_acls | Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `true` | no |
| kms_arn | The AWS KMS master key ID used for the SSE-KMS encryption. | `string` | `null` | no |
| kms_rotation | Whether key rotation is enabled. | `bool` | `true` | no |
| lifecycle_rule | Map containing configuration of object lifecycle management. | `any` | `{}` | no |
| logging | Bucket logging configuration. | `map(string)` | `{}` | no |
| object_ownership | True - BucketOwnerPreferred, false - BucketOwnerEnforced. | `bool` | `true` | no |
| ownership_s3_control | Enable or Disable ownership control for s3 buckets. | `bool` | `true` | no |
| policy | A valid bucket policy JSON document | `string` | `null` | no |
| replication | Map containing cross-region replication configuration. | `map(string)` | `{}` | no |
| restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `true` | no |
| tags | A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |
| use_kms | Create and use KMS key Stored in AWS Key Management Service (SSE-KMS) for encrypting the bucket. If false, use Amazon S3-Managed Keys (SSE-S3). Has no effect if encrypt_bucket is off. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | S3 bucket outputs |

## Usage

### S3 with KMS encryption
```terraform
module "s3-kms-default" {
  source = "../../modules/s3"

  name       = "ait-s3-kms-default"
  tags       = local.base_tags
}

module "s3-kms" {
  source = "../../modules/s3"

  name       = "ait-s3-kms"
  use_kms    = true
  tags       = local.base_tags
}
```

### S3 with AES256 encryption
```terraform
module "s3-aes256" {
  source = "../../modules/s3"

  name       = "ait-s3-aes256"
  use_kms    = false
  tags       = local.base_tags
}
```

### S3 with AES256 encryption
```terraform
module "s3-without-encryption" {
  source = "../../modules/s3"

  name              = "ait-s3-without-encryption"
  enable_encryption = false
  tags              = local.base_tags
}
```
<!-- END_TF_DOCS -->