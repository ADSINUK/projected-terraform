### Variables
variable "minimum_password_length" {
  description = "Minimum length to require for user passwords."
  type        = number
  default     = 14
}
variable "require_uppercase_characters" {
  description = "Whether to require uppercase characters for user passwords."
  type        = bool
  default     = true
}
variable "require_lowercase_characters" {
  description = "Whether to require lowercase characters for user passwords."
  type        = bool
  default     = true
}
variable "require_numbers" {
  description = "Whether to require numbers for user passwords."
  type        = bool
  default     = true
}
variable "require_symbols" {
  description = "Whether to require symbols for user passwords."
  type        = bool
  default     = true
}
variable "allow_users_to_change_password" {
  description = "Whether to allow users to change their own password."
  type        = bool
  default     = true
}
variable "max_password_age" {
  description = "The number of days that an user password is valid."
  type        = number
  default     = 90
}
variable "hard_expiry" {
  description = "(Optional) Whether users are prevented from setting a new password after their password has expired (i.e., require administrator reset)."
  type        = bool
  default     = false
}
