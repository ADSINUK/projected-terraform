### Variables
variable "bucket" {
  description = "The name of the bucket."
  type        = string
}
variable "enable_sse" {
  description = "Whether Amazon S3 should enable server-side encryption for this bucket."
  type        = bool
  default     = true
}
variable "enable_versioning" {
  description = "A boolean, that enable versioning."
  type        = bool
  default     = true
}
variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}
