### Variables
variable "name" {
  description = "The name of the bucket. If omitted."
  type        = string
}
variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}
variable "policy" {
  description = "A valid bucket policy JSON document"
  type        = string
  default     = null
}
variable "acl" {
  description = "The canned ACL to apply. Defaults to 'private'"
  type        = string
  default     = "private"
}
variable "deny_insecure_transport" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached."
  type        = bool
  default     = false
}
variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}
variable "force_destroy" {
  description = "(Optional) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = true
}
variable "attach_policy_website" {
  description = "A boolean, that enable static web-site hosting."
  type        = bool
  default     = false
}
variable "enable_cors" {
  description = "A boolean, that enable cors."
  type        = bool
  default     = false
}
variable "cors_rule" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = []
}
variable "enable_versioning" {
  description = "A boolean, that enables versioning."
  type        = bool
  default     = false
}
variable "replication" {
  description = "Map containing cross-region replication configuration."
  type        = map(string)
  default     = {}
}
variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}
variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}
variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}
variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}
variable "enable_encryption" {
  description = "Whether Amazon S3 should enable server-side encryption for this bucket."
  type        = bool
  default     = true
}
variable "use_kms" {
  description = "Create and use KMS key Stored in AWS Key Management Service (SSE-KMS) for encrypting the bucket. If false, use Amazon S3-Managed Keys (SSE-S3). Has no effect if encrypt_bucket is off."
  type        = bool
  default     = true
}
variable "kms_arn" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption."
  type        = string
  default     = null
}
variable "kms_rotation" {
  description = "Whether key rotation is enabled."
  type        = bool
  default     = true
}
variable "logging" {
  description = "Bucket logging configuration."
  type        = map(string)
  default     = {}
}
variable "object_ownership" {
  description = "True - BucketOwnerPreferred, false - BucketOwnerEnforced."
  type        = bool
  default     = true
}
variable "ownership_s3_control" {
  description = "Enable or Disable ownership control for s3 buckets."
  type        = bool
  default     = true
}
variable "lifecycle_rule" {
  description = "Map containing configuration of object lifecycle management."
  type        = any
  default     = {}
}
