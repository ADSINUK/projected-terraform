### EBS encryption
# Enabled by default encryption in the current AWS region
resource "aws_ebs_encryption_by_default" "enabled" {
  enabled = true
}
