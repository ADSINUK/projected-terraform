### Variables
variable "iam_policy_name_prefix" {
  description = "IAM policy name prefix. Will be appended with `-region-restriction-policy`"
  type        = string
}
variable "groups" {
  default     = []
  description = "Region restriction for the members in these group.(Optional, default '[]')"
  type        = list(string)
}
variable "allow_regions" {
  description = "List of allowed regions."
  type        = list(any)
  default     = ["us-east-1"]
}
