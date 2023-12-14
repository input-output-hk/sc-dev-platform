locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  profile = local.account_vars.locals.aws_profile
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "route53" {
  config_path = "${get_repo_root()}/infra/global/route53/zones"
}

terraform {
  source = "${get_repo_root()}/infra/modules/acm"
}

inputs = {
  domains = {
    "scdev.aws.iohkdev.io"      = dependency.route53.outputs.route53_zone_zone_id["scdev.aws.iohkdev.io"]
    "prod.scdev.aws.iohkdev.io" = dependency.route53.outputs.route53_zone_zone_id["scdev.aws.iohkdev.io"]
    "demo.scdev.aws.iohkdev.io" = dependency.route53.outputs.route53_zone_zone_id["scdev.aws.iohkdev.io"]
    "test.scdev.aws.iohkdev.io" = dependency.route53.outputs.route53_zone_zone_id["scdev.aws.iohkdev.io"]
    "runner.marlowe.iohk.io"    = dependency.route53.outputs.route53_zone_zone_id["marlowe.iohk.io"]
    "marlowe.iohk.io"           = dependency.route53.outputs.route53_zone_zone_id["marlowe.iohk.io"]
  }
}
