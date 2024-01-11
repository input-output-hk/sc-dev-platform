locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env          = local.environment_vars.locals.environment
  region       = local.environment_vars.locals.aws_region
  project      = local.environment_vars.locals.project
  tribe        = local.account_vars.locals.tribe
  account_id   = local.account_vars.locals.aws_account_id
  account_name = local.account_vars.locals.account_name
  users        = local.account_vars.locals.users

  # Defining KMS key administrators
  key_administrators = concat([
    "arn:aws:iam::${local.account_id}:role/dapps-world",
    "arn:aws:iam::${local.account_id}:role/OrganizationAccountAccessRole",
    ], [
    for user in local.users : "arn:aws:iam::${local.account_id}:user/${user}"
  ])
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-kms?ref=v2.1.0"
}

inputs = {
  enable_key_rotation   = false
  multi_region          = false
  enable_default_policy = false
  key_owners            = ["arn:aws:iam::${local.account_id}:root"]
  key_administrators    = local.key_administrators
  key_users             = local.key_administrators
  aliases               = [local.account_name, "${local.account_name}-${local.env}"]
}