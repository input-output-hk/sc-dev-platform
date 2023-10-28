locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  domains = local.environment_vars.locals.route53_config
  profile = local.account_vars.locals.aws_profile
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/input-output-hk/sc-dev-platform.git//infra/modules/acm?ref=8461d7876cb82ca9c4971b53415a0f60863f0b48"
}

inputs = {
  domains = local.domains
}