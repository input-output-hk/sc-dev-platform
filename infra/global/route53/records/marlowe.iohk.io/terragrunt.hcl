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

  zone_name = dependency.zones.outputs.route53_zone_name["marlowe.iohk.io"]

  records = [
    {
      name = "play"
      type = "NS"
      ttl = 300
      records = dependency.zones.outputs.route53_zone_name_servers["play.marlowe.iohk.io"]
    },
    {
      name = "play-test"
      type = "NS" 
      ttl = 300
      records = dependency.zones.outputs.route53_zone_name_servers["play-test.marlowe.iohk.io"]
    },
    {
      name = "runner"
      type = "NS"
      ttl = 300
      records = dependency.zones.outputs.route53_zone_name_servers["runner.marlowe.iohk.io"]
    },
    {
      name = "mpc"
      type = "CNAME"
      ttl = 300
      records = ["8848114.group14.sites.hubspot.net."]
    },
    {
      name = "docs" 
      type = "CNAME" 
      ttl = 300
      records = ["cname.vercel-dns.com."]
    },
    {
      name = ""
      type = "A"
      ttl = 300
      records = ["76.76.21.21"]
    }
  ]
}
