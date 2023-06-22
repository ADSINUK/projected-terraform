# IAM policy to enforce MFA

Terraform module to create IAM policy that enforces user to setup MFA.

What does this policy do?
* `AllowViewAccountInfo`: allows the user to view details about a virtual MFA device that is enabled for the user.
* `AllowManageOwnVirtualMFADevice`: allows the user to create and delete their own virtual MFA device.
* `AllowManageOwnUserMFA`: allows the user to view or manage their own virtual, U2F, or hardware MFA device.
* `DenyAllExceptListedIfNoMFA`: denies access to every action in all AWS services, except a few listed actions, but only if the user is not signed in with MFA.

This policy should be treated as a baseline according to AWS well-architected recommendations. If an IAM user with this policy is not MFA-authenticated, this policy denies access to all AWS actions except those necessary to authenticate using MFA.