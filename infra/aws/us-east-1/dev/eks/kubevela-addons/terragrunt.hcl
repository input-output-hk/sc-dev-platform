locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Generators
  providers = read_terragrunt_config(find_in_parent_folders("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl"))

  # Extract out common variables for reuse
  env               = local.environment_vars.locals.environment
  account_id        = local.account_vars.locals.aws_account_id
  profile           = local.account_vars.locals.aws_profile
}

include "root" {
  path = find_in_parent_folders()
}

generate = local.providers.generate

terraform {
  source = "../../../../../infra/modules/kubevela-addons"
}

dependency "eks" {
  config_path = "../cluster"
}

dependency "security_group" {
  config_path = "../../rds/security-group"
}

inputs = {
  aws_profile                        = local.profile
  env                                = local.env
  account_id                         = local.account_id
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_version                    = dependency.eks.outputs.cluster_version
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn
  rds_security_groups                = [dependency.security_group.outputs.security_group_id]
  enable_addons                      = true 
  enable_cardano_nodes               = true 
  enable_dex                         = false
}
