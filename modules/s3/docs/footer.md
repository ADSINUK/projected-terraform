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

module "s3-kms-arn" {
  source = "../../modules/s3"
  
  name       = "ait-s3-kms-arn"
  kms_arn    = "arn:aws:kms:eu-west-1:XXXXXXXXXXXX:key/XXX..."
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

### S3 without encryption
```terraform
module "s3-without-encryption" {
  source = "../../modules/s3"

  name              = "ait-s3-without-encryption"
  enable_encryption = false
  tags              = local.base_tags
}
```