### Outputs
# General
variable "name" {
  description = "Basename for resources in the module"
  type        = string
}
variable "tags" {
  description = "A mapping of tags to assign to resources"
  type        = map(string)
}
# Cloudwatch variables
variable "cloudwatch_log_group_session_logger" {
  description = "CW Log Group name"
  type        = string
  default     = "/aws/ssm/session-logger"
}
# Key Management Service variables
variable "kms_key_rotation" {
  description = "Enable automatic KMS Key rotation"
  type        = bool
  default     = true
}
# S3 variables
variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}
variable "bucket_prefix" {
  description = "Bucket prefix"
  type        = string
  default     = "session-logging"
}
# SSM variables
variable "ssm_document_session_name" {
  description = "Name of SSM Document Session"
  default     = "SSM-SessionManagerRunShell"
  type        = string
}
variable "enable_log_to_s3" {
  description = "Enable shipping logs into S3 bucket"
  type        = bool
  default     = false
}
variable "enable_log_to_cloudwatch" {
  description = "Enable shipping logs into CloudWatch"
  type        = bool
  default     = false
}
variable "linux_shell_profile" {
  description = "Linux shell profile"
  type        = string
  default     = ""
}
variable "windows_shell_profile" {
  description = "Windows shell profile"
  type        = string
  default     = ""
}
