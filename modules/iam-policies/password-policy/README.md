# MODULE: Password Policy

## General

This module Manages Password Policy for the AWS Account.


## Module details

Module creates IAM password policy.

Module parameters are:

* `minimum_password_length` (default = 14)

	Minimum length to require for user passwords.

* `require_uppercase_characters` (default = true)

	Whether to require uppercase characters for user passwords.

* `require_lowercase_characters` (default = true)

	Whether to require lowercase characters for user passwords.

* `require_numbers` (default = true)

	Whether to require numbers for user passwords.

* `require_symbols` (default = true)

	Whether to require symbols for user passwords.

* `allow_users_to_change_password` (default = true)

	Whether to allow users to change their own password.

* `max_password_age` (default = 90)

	The number of days that an user password is valid.

--
Copyright (c) 2023 Automat-IT
