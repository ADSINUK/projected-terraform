### Variables
variable "expire_days" {
  description = "The expiration for the lifecycle of the object in the form of date, days and, whether the object has a delete marker"
  type        = number
  default     = 365
}
variable "basename" {
  description = "Basename for resources in the module"
  type        = string
}
variable "bucket" {
  description = "S3 bucket for CloudTrail events"
  type        = string
}
variable "aws_account" {
  description = "AWS account ID"
  type        = string
}
variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "force_destroy" {
  description = "All objects (including any locked objects) should be deleted from the bucket during destroy module"
  type        = bool
  default     = true
}
variable "tags" {
  description = "A map of tags to assign to the object"
  type        = map(string)
}
variable "kms_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}
variable "enable_kms_encryption" {
  description = "Enable KMS encryption"
  type        = bool
  default     = true
}
variable "log_file_validation" {
  description = "Whether log file integrity validation is enabled"
  type        = bool
  default     = true
}
variable "logging" {
  description = "Access logging for s3 cloudtrail bucket configuration"
  type        = map(string)
  default     = {}
}
variable "enable_cloudwatch_logs" {
  description = "Whether CloudWatch logs is enabled"
  type        = bool
  default     = false
}
variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = "aws-cloudtrail"
}
variable "cloudwatch_log_group_retention" {
  description = "CloudWatch log group retentaion"
  type        = number
  default     = 180
}
