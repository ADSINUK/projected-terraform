resource "aws_security_group" "ec2" {
  name        = "${local.basename}-Windows"
  description = "Access to customer-specific EC2 instances"
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = {
      RDP     = 3389
      Octopus = 10933
    }
    content {
      description = tostring(ingress.key)
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [local.mgmt_vpc_cidr]
    }
  }
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_shuffle" "subnet_id" {
  for_each     = toset(["admin", "api", "app"])
  input        = module.vpc.private_subnets
  result_count = 1
}

module "admin" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.1.0"

  name                    = "${local.basename}-admin"
  ami                     = data.aws_ami.admin.image_id
  instance_type           = "m6i.large"
  subnet_id               = random_shuffle.subnet_id["admin"].result.0
  disable_api_termination = true
  key_name                = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids      = [aws_security_group.ec2.id]
  create_iam_instance_profile = true
  iam_role_name               = "${local.basename}-admin"
  iam_role_policies = {
    SSM = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  }
  enable_volume_tags = true
  root_block_device = [{
    encrypted   = true
    volume_type = "gp3"
  }]
}

module "api" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.1.0"

  name                    = "${local.basename}-api"
  ami                     = data.aws_ami.api.image_id
  instance_type           = "m6i.large"
  subnet_id               = random_shuffle.subnet_id["api"].result.0
  disable_api_termination = true
  key_name                = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids      = [aws_security_group.ec2.id]
  create_iam_instance_profile = true
  iam_role_name               = "${local.basename}-api"
  iam_role_policies = {
    SSM = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  }
  enable_volume_tags = true
  root_block_device = [{
    encrypted   = true
    volume_type = "gp3"
  }]
}

module "app" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.1.0"

  name                    = "${local.basename}-app"
  ami                     = data.aws_ami.app.image_id
  instance_type           = "m6i.large"
  subnet_id               = random_shuffle.subnet_id["app"].result.0
  disable_api_termination = true
  key_name                = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids      = [aws_security_group.ec2.id]
  create_iam_instance_profile = true
  iam_role_name               = "${local.basename}-app"
  iam_role_policies = {
    SSM = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  }
  enable_volume_tags = true
  root_block_device = [{
    encrypted   = true
    volume_type = "gp3"
  }]
}
