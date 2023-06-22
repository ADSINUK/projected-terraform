### Data sources
# Availability zones
data "aws_availability_zones" "aws-azs" {}

# Latest CentOS 7 AMI in the region (needs manual subscription)
data "aws_ami" "centos7" {
  executable_users = ["all"]
  owners           = ["aws-marketplace"]
  most_recent      = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "product-code"
    values = ["cvugziknvmxgqna9noibqnnsy"]
  }
}

# Latest Amazon Linux 2 AMI in the region
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "octopus" {
  most_recent = true
  owners      = [local.aws_account]
  filter {
    name   = "name"
    values = ["Octopus"]
  }
}

data "aws_ami" "teamcity" {
  most_recent = true
  owners      = [local.aws_account]
  filter {
    name   = "name"
    values = ["TeamCity"]
  }
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

### Handy locals
locals {
  zone_names      = slice(data.aws_availability_zones.aws-azs.names, 0, var.total_azs)
  zone_ids        = slice(data.aws_availability_zones.aws-azs.zone_ids, 0, var.total_azs)
  centos_ami      = data.aws_ami.centos7.image_id
  amz_linux_2_ami = data.aws_ami.amazon-linux-2.image_id
}

### Outputs
# Pass some common values to all other environments to speed up refresh stage
output "zone_names" { value = local.zone_names }
output "zone_ids" { value = local.zone_ids }
output "centos_ami" { value = local.centos_ami } # NOTE: This would be different in different regions!
