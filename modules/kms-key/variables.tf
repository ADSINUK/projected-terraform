### Variables
variable "aws_account" {
  type        = string
  description = "AWS account ID"
}
variable "aws_region" {
  type        = string
  description = "AWS region"
}
variable "aws_services" {
  type        = list(string)
  default     = []
  description = "The list of AWS services this KMS Key's IAM policy will allow usage via"
}
variable "name" {
  type        = string
  description = "The name for the KMS Key"
}
variable "description" {
  type        = string
  default     = ""
  description = "Optional text description for the KMS Key"
}
variable "key_rotation" {
  type        = bool
  default     = true
  description = "Enable automatic KMS Key rotation"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
