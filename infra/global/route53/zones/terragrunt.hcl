locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project       = local.environment_vars.locals.project
  tribe         = local.account_vars.locals.tribe
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53//modules/zones?ref=v2.10.2"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  zones = {
    "scdev.aws.iohkdev.io" = {
      comment = "Smart Contracts Tribe Development Platform"
    }

    "scdev-test.aws.iohkdev.io" = {
      comment = "Smart Contracts Tribe Development Platform Test Domain"
    }

    "marlowe.iohk.io" = {
      comment = "Marlowe Production Domain"
    }

    "play.marlowe.iohk.io" = {
      comment = "Marlowe Playground Production Domain"
    }

    "play-test.marlowe.iohk.io" = {
      comment = "Marlowe Playground Test Domain"
    }

    "runner.marlowe.iohk.io" = {
      comment = "Marlowe Runner Production Domain"
    }

    "marlowe-finance.io" = {} 
  }
}
