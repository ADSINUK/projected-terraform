resource "aws_security_group" "ec2_mgmt" {
  name        = "${local.basename}-Windows"
  description = "Access to customer-specific EC2 instances"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description     = "RDP"
    from_port       = 3389
    to_port         = 3389
    protocol        = "tcp"
    security_groups = [module.openvpn[0].sg]
  }
  dynamic "ingress" {
    for_each = [80, 4444]
    content {
      description     = "HTTP access"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [module.alb.security_group_id]
      cidr_blocks     = [local.vpc_cidr]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_shuffle" "octopus_subnet_id" {
  input        = module.vpc.private_subnets
  result_count = 1
}

module "octopus" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.1.0"

  name                    = "${local.basename}-Octopus"
  ami                     = data.aws_ami.octopus.image_id
  instance_type           = "m6i.large"
  subnet_id               = random_shuffle.octopus_subnet_id.result.0
  disable_api_termination = true
  key_name                = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids      = [aws_security_group.ec2_mgmt.id]
  create_iam_instance_profile = true
  iam_role_name               = "${local.basename}-Octopus"
  iam_role_policies = {
    SSM = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  }
  enable_volume_tags = true
  root_block_device = [{
    encrypted   = true
    volume_type = "gp3"
  }]
}

resource "random_shuffle" "teamcity_subnet_id" {
  input        = module.vpc.private_subnets
  result_count = 1
}

module "teamcity" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.1.0"

  name                    = "${local.basename}-TeamCity"
  ami                     = data.aws_ami.teamcity.image_id
  instance_type           = "r6i.large"
  subnet_id               = random_shuffle.teamcity_subnet_id.result.0
  disable_api_termination = true
  key_name                = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids      = [aws_security_group.ec2_mgmt.id]
  create_iam_instance_profile = true
  iam_role_name               = "${local.basename}-TeamCity"
  iam_role_policies = {
    SSM = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  }
  enable_volume_tags = true
  root_block_device = [{
    encrypted   = true
    volume_type = "gp3"
  }]
}
