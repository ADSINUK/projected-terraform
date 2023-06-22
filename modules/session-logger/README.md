# A Terraform module to setup AWS Systems Manager Session Manager.
This module creates the a SSM document to support encrypted session manager communication and logs. 
It also creates a KMS key, S3 bucket, and CloudWatch Log group to store logs.
  

## Inputs for base module
|       Name                            |      Description           |  Type      | Default                    | Required |      Example            |
|---------------------------------------|----------------------------|------------|----------------------------|----------|-------------------------|
| bucket_name                           | name of the log s3-bucket  | string     | -                          | -        | session-bucket          |
| enable_kms_encryption                 | enable kms encryption      | bool       | false                      | -        | -                       |
| enable_log_to_cloudwatch              | enable log to cloudwatch   | bool       | false                      | -        | -                       |
| enable_log_to_s3                      | enable log to s3 bucket    | bool       | false                      | -        | -                       |         
| cloudwatch_log_group_session_logger   | cloudwatch log group name  | string     | /aws/ssm/session-logger    | -        | /aws/ssm/session-logger |
| ssm_document_session_name             | ssm document name          | string     | SSM-SessionManagerRunShell | -        | -                       |
| log_archive_days                      | log s3 archive days        | number     | 30                         | -        | 30                      |
| log_expire_days                       | log s3 expire days         | number     | 365                        | -        | 365                     |
| linux_shell_profile                   | linux sgell profile        | string     | ""                         | -        | true                    |
| windows_shell_profile                 | windows shell profile      | string     | ""                         | -        | true                    |

## Example
```
### AWS Systems Manager Session Manager
module "session-logger" {
  count = var.install_session_logger ? 1 : 0

  source = "../../modules/session-logger"

  bucket_name               = "session-logger.${var.aws_region}.${var.project_domain}"
  name                      = local.basename
  tags                      = local.base_tags
  enable_kms_encryption     = true
  enable_log_to_cloudwatch  = true
  enable_log_to_s3          = true
}

```
