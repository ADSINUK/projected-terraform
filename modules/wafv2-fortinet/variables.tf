### Variables
variable "name" {
  description = "A friendly name of the IP set"
  type        = string
}
variable "scope" {
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL"
  type        = string
}
variable "ip_address_version" {
  description = "Specify IPV4 or IPV6. Valid values are IPV4 or IPV6"
  type        = string
  default     = "IPV4"
}
variable "blacklisted_ips" {
  description = "IPs to be added to the blacklist"
  type        = list(any)
  default     = []
}
variable "whitelisted_ips" {
  description = "IPs to be added to the whitelist"
  type        = list(any)
  default     = []
}
variable "enable_logging" {
  description = "Enable logging"
  type        = bool
  default     = true
}
variable "log_bucket_arn" {
  description = "Bucket ARN for logging"
  type        = string
  default     = ""
}
variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# vim:filetype=terraform ts=2 sw=2 et:
