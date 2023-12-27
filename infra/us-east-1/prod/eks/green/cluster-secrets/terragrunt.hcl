locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file("./cluster-secrets.enc.yaml"))

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
  source = "${get_repo_root()}/infra/modules/cluster-secrets"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name = "${dependency.eks.outputs.cluster_name}"
  namespace    = "marlowe" 

  jwt-signature                    = local.secret_vars.jwt-signature.JWT_SIGNATURE
  jwt-signature-input-properties   = local.secret_vars.jwt-signature.input-properties
  gh-oauth-callbackPath            = local.secret_vars.gh-oauth.callbackPath
  gh-oauth-clientID                = local.secret_vars.gh-oauth.clientID
  gh-oauth-clientSecret            = local.secret_vars.gh-oauth.clientSecret
  gh-oauth-input-properties        = local.secret_vars.gh-oauth.input-properties
  iohk-ghcr-creds-dockerconfigjson = local.secret_vars.iohk-ghcr-creds.dockerconfigjson
  iohk-ghcr-creds-input-properties = local.secret_vars.iohk-ghcr-creds.input-properties
}
