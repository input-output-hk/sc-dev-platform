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
}

terraform {
  source = "../../../modules/github-webhook-repo"
}

dependency "atlantis" {
  config_path = "${get_repo_root()}/infra/us-east-1/mgmt/atlantis"
}

include {
  path = find_in_parent_folders()
}

inputs = {
    repositories = [
        "github.com/input-output-hk/sc-dev-platform"
    ]
    webhook_url = dependency.atlantis.outputs.url
    github_token = "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"
}