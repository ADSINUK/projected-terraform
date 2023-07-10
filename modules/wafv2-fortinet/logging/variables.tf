### Variables
variable "name" {
  description = "Name for resources in the module"
  type        = string
}
variable "log_bucket_arn" {
  description = "Bucket ARN for logging"
  type        = string
}
variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
variable "encryption_enabled" {
  description = "Enable encryption"
  type        = bool
  default     = false
}
variable "encryption_key_type" {
  description = "Encryption key type"
  type        = string
  default     = "AWS_OWNED_CMK"
}
variable "encryption_key_arn" {
  description = "Encryption key ARN"
  type        = string
  default     = null
}
variable "waf_acl_arn" {
  description = "WAF ACL ARN"
  type        = string
}

# vim:filetype=terraform ts=2 sw=2 et:
