locals {

  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project        = local.account_vars.locals.project
  app            = "marlowe-runtime"
  database_name  = "${local.project}-${local.app}-database"

  tags = {
    Environment = "prod"
    Terraform   = "true"
    Project     = local.project
    Resource    = local.database_name
  }

}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-rds/modules/db_instance"
}

inputs = {
  identifier            = local.database_name
  instance_class        = "db.m5d.2xlarge"
  multi_az              = true
  max_allocated_storage = 3000

  db_subnet_group_name   = "default-vpc-0a68a5d196ce5e1d1"
  vpc_security_group_ids = ["sg-0c2ff87114e5f6ec1"]

  snapshot_identifier     = "rds:runtime-database-1-2023-08-22-08-02"
  skip_final_snapshot     = false
  copy_tags_to_snapshot   = true
  backup_retention_period = 21

  performance_insights_enabled          = true
  performance_insights_retention_period = 31

  apply_immediately = true

  tags = local.tags
}
