# Module: Log Bucket

### Description

This module is designed for centralized storage of logs from such resources as:

- S3 Bucket
- LoadBalancer (Application/Network/Classic)
- SSM Session Manager
- VPC Flow Logs

### Input parameters
Name | Description | Type | Default | Required |
--- | --- | --- | --- |--- 
bucket | The name of the bucket | string | N/A | Yes
enable_sse | Whether Amazon S3 should enable server-side encryption for this bucket | bool | true | No
enable_versioning | A boolean, that enable versioning | bool | true | No
tags | A mapping of tags to assign to the bucket | map(string) | {} | No

### Output parameters
Name | Description | Type |
--- | --- | --- 
s3_bucket_id | The name of the bucket | string
s3_bucket_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname | string

[Powered by Automat-IT](https://www.automat-it.com/)
