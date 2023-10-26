locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  hostnames   = local.environment_vars.locals.hostnames
  domain_name = split("*.", local.hostnames[0])[1]
  zone_id     = local.environment_vars.locals.zone_id
  profile     = local.account_vars.locals.aws_profile
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-acm?ref=v4.5.0"
}

inputs = {
  domain_name               = local.domain_name
  zone_id                   = local.zone_id
  subject_alternative_names = local.hostnames
  wait_for_validation       = true
}