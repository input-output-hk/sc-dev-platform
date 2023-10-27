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
  source = "github.com/input-output-hk/sc-dev-platform.git//infra/modules/acm?ref=ff9f7de886fca6f9c9f4444d06e6b65b3f1180b9"
}

inputs = {
  domains = local.domains
}