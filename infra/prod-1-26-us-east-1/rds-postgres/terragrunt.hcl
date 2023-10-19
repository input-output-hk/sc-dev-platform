locals {

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project = local.account_vars.locals.project
  env     = local.environment_vars.locals.environment
  app     = "marlowe-runtime"

  database_name = "${local.project}-${local.app}-${local.env}-database"

  tags = {
    Environment = "prod"
    Terraform   = "true"
    Project     = local.project
  }

}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "eks" {
  config_path = "../eks"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-rds//.?ref=v6.1.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  identifier            = local.database_name
  instance_class        = "db.m6g.2xlarge"
  multi_az              = true
  storage_type          = "gp3"
  allocated_storage     = 1500
  max_allocated_storage = 3000
  domain                = ""
  publicly_accessible   = false
  monitoring_interval   = 60
  monitoring_role_arn   = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/rds-monitoring-role"

  username = "postgres"

  create_db_subnet_group = true
  subnet_ids             = dependency.vpc.outputs.intra_subnets

  vpc_security_group_ids = [dependency.eks.outputs.node_security_group_id]

  engine               = "postgres"
  major_engine_version = "15"
  family               = "postgres15"

  # snapshot_identifier     = "rds:dapps-marlowe-runtime-database-2023-10-09-07-59"
  skip_final_snapshot     = false
  copy_tags_to_snapshot   = true
  backup_retention_period = 21

  performance_insights_enabled          = true
  performance_insights_retention_period = 31

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  auto_minor_version_upgrade = false
  apply_immediately          = true
  deletion_protection        = true

  tags = local.tags
}