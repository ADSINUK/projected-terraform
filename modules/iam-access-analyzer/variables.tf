### Variables
variable "analyzer_name" {
  description = "Name of the Analyzer"
  type        = string
}
variable "is_organization" {
  description = "Set this to true if the IAM Access Analyzer should be enabled in an Organization Master Account"
  default     = false
  type        = bool
}
variable "tags" {
  description = "Map of tags for IAM Access Analyzer"
  type        = map(string)
}
