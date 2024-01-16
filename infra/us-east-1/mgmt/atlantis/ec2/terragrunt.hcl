locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  project     = local.environment_vars.locals.project
  cidr_prefix = local.environment_vars.locals.cidr_prefix
  tribe       = local.account_vars.locals.tribe
  name        = "scde"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v5.6.0"
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
   name = local.name

   subnet_id              = dependency.vpc.outputs.public_subnets[0]
}

