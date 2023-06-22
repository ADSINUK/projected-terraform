### Variables
variable "aws_region" {
  description = "aws region in which module will be deployed in"
  type        = string
}
variable "aws_account" {
  description = "aws account id"
  type        = string
}
variable "name" {
  description = "Name used to in different parts of module for example for lambda function, sg etc."
  type        = string
}
variable "tags" {
  description = "A map of tags to assign to the objects in module"
  type        = map(string)
}
variable "bucket" {
  description = "S3 bucket arn"
  type = object({
    arn = string
  })
}
variable "guardduty_kms_key" {
  description = "KMS key arn"
  type = object({
    arn = string
  })
}
#Activate or deactivate EKS and S3 protection
# Turned off by default
variable "eks_protection" {
  description = "Activate or deactivate EKS protection"
  type        = bool
  default     = false
}
variable "s3_protection" {
  description = "Activate or deactivate S3 protection"
  type        = bool
  default     = false
}
variable "guardduty_sqs_arn" {
  description = "GuardDuty SQS arn"
  type        = string
}
variable "guardduty_sns_https_subscriptions" {
  description = "list of sns https subscriptions"
  type        = list(string)
  default     = []
}
