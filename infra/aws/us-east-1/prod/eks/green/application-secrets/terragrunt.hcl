locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # Generators
  providers = read_terragrunt_config(find_in_parent_folders("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl"))

  # Extract out common variables for reuse
  env               = local.environment_vars.locals.environment
  region            = local.environment_vars.locals.aws_region
  profile           = local.account_vars.locals.aws_profile
  account_id        = local.account_vars.locals.aws_account_id
}

include "root" {
  path = find_in_parent_folders()
}

generate = local.providers.generate

terraform {
  source = "${get_repo_root()}/infra/modules/application-secrets"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name = "${dependency.eks.outputs.cluster_name}"
  marlowe_oracle_preprod_address = local.secret_vars.marlowe_oracle.preprod.address
  marlowe_oracle_preprod_skey    = local.secret_vars.marlowe_oracle.preprod.skey
  marlowe_oracle_preprod_vkey    = local.secret_vars.marlowe_oracle.preprod.vkey
  nixbuild_net_token             = local.secret_vars.nixbuild_net
}
