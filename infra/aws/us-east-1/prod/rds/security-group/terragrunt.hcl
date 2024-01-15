locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  security_group_name = "rds-${local.env}-security-group"
}

dependency "vpc" {
  config_path = "../../vpc"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group//modules/postgresql?ref=v5.1.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  name                = local.security_group_name
  vpc_id              = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
}