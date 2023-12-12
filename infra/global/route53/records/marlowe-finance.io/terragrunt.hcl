locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project       = local.environment_vars.locals.project
  tribe         = local.account_vars.locals.tribe
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53//modules/records?ref=v2.10.2"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "zones" {
  config_path = "../../zones"
}

inputs = {

  zone_name = dependency.zones.outputs.route53_zone_name["marlowe-finance.io"]

  records = [
    {
      name = ""
      type = "A"
      alias = {
        name = "s3-website.eu-central-1.amazonaws.com."
        zone_id = "Z21DNDUVLTQW6Q"
      }
    },
    {
      name = "play"
      type = "A"
      alias = {
        name = "s3-website.eu-central-1.amazonaws.com."
        zone_id = "Z21DNDUVLTQW6Q"
      }
    }
  ]
}
