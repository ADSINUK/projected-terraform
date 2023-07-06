resource "random_password" "mssql" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "rds_password" {
  name  = upper("/${var.project_env}/rds_password")
  type  = "SecureString"
  value = random_password.mssql.result
}

module "database" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.9.0"

  identifier                       = lower(local.basename)
  deletion_protection              = true
  engine                           = "sqlserver-se"
  family                           = "sqlserver-se-14.0"
  engine_version                   = "14.00"
  major_engine_version             = "14.00"
  instance_class                   = "db.m6i.large"
  allocated_storage                = 20
  max_allocated_storage            = 100
  storage_encrypted                = true
  username                         = "admin"
  create_random_password           = false
  password                         = random_password.mssql.result
  vpc_security_group_ids           = [aws_security_group.rds-sg_allow.id]
  db_subnet_group_name             = module.vpc.database_subnet_group_name
  multi_az                         = true
  port                             = 1433
  maintenance_window               = "Mon:00:00-Mon:03:00"
  backup_window                    = "03:00-06:00"
  backup_retention_period          = 1
  license_model                    = "license-included"
  timezone                         = "GMT Standard Time"
  final_snapshot_identifier_prefix = "final-${local.basename}"
}

resource "aws_security_group" "rds-sg_allow" {
  name        = "${local.basename}-rds-sg"
  description = "Access to ${var.project_env} RDS DB"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description     = "SQL Server access"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
    cidr_blocks     = [local.mgmt_vpc_cidr]
  }
}
