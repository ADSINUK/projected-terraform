### Variables
# General
variable "aws_region" {
  description = "aws region in which module will be deployed in"
  type        = string
}
variable "aws_account" {
  description = "aws account id"
  type        = string
}
variable "project_name" {
  description = "Name of the project"
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
# S3 Bucket
variable "expire_days" {
  description = "Number of days after which all objects in S3 bucket would be deleted"
  type        = number
  default     = 365
}
variable "bucket" {
  description = "Name of an S3 bucket"
  type        = string
}
variable "force_destroy" {
  description = "Force destroy of an S3-guardduty module"
  type        = bool
  default     = true
}
variable "log_bucket_id" {
  description = "ID of an S3 bucket to store logs in"
  type        = string
}
# Network
variable "vpc_id" {
  description = "VPC ID where resources will be deployed in"
  type        = string
}
variable "subnet_ids" {
  description = "List of subnets associated with VPC"
  type        = list(string)
}
