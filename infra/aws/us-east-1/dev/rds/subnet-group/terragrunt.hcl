locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  subnet_group_name = "${local.env}-subnet-group"
}

dependency "vpc" {
  config_path = "../../vpc"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-rds//.?ref=v6.1.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  // Disabling all submodules but db_subnet_group
  create_db_instance        = false
  create_db_option_group    = false
  create_db_parameter_group = false

  // Defining SubnetGroup inputs
  create_db_subnet_group          = true
  identifier                      = local.subnet_group_name
  db_subnet_group_use_name_prefix = false
  db_subnet_group_description     = "SubnetGroup for SCDE Dev Environment"
  subnet_ids                      = dependency.vpc.outputs.intra_subnets
}