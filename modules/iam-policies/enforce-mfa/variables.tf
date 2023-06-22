### Variables
variable "iam_policy_name_prefix" {
  description = "IAM policy name prefix. Will be appended with `-iam-enforce-mfa-policy`"
  type        = string
}
variable "manage_own_access_keys" {
  default     = true
  description = "Allow a new AWS secret access key and corresponding AWS access key ID for the specified user."
  type        = bool
}
variable "groups" {
  default     = []
  description = "Enforce MFA for the members in these groups. (Optional, default '[]')"
  type        = list(string)
}
