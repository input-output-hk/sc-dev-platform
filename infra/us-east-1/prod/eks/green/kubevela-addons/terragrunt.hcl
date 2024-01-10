locals {
  # Automatically load environment-level variables
  environment_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars        = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  secret_vars         = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # Generators
  providers = read_terragrunt_config(find_in_parent_folders("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl"))

  # Extract out common variables for reuse
  env               = local.environment_vars.locals.environment
  region            = local.environment_vars.locals.aws_region
  profile           = local.account_vars.locals.aws_profile
  account_id        = local.account_vars.locals.aws_account_id
  dex_client_id     = local.secret_vars.dex.clientID
  dex_client_secret = local.secret_vars.dex.clientSecret
}

include "root" {
  path = find_in_parent_folders()
}

generate = local.providers.generate

terraform {
  source = "${get_repo_root()}/infra/modules/kubevela-addons"
}

dependency "eks" {
  config_path = "../eks"
}

dependency "security_group" {
  config_path = "../../../rds/security-group"
}

inputs = {
  aws_profile                        = local.profile
  account_id                         = local.account_id
  env                                = local.env
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_version                    = dependency.eks.outputs.cluster_version
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn
  rds_security_groups                = [dependency.security_group.outputs.security_group_id]
  velaux_domain                      = "vela.scdev.aws.iohkdev.io"
  dex_client_id                      = local.dex_client_id
  dex_client_secret                  = local.dex_client_secret

  secrets_namespace                  = "marlowe"
  cluster_secrets = {
    jwt_signature                    = local.secret_vars.jwt-signature.JWT_SIGNATURE
    jwt_signature_input_properties   = local.secret_vars.jwt-signature.input-properties
    gh_oauth_callbackPath            = local.secret_vars.gh-oauth.callbackPath
    gh_oauth_clientID                = local.secret_vars.gh-oauth.clientID
    gh_oauth_clientSecret            = local.secret_vars.gh-oauth.clientSecret
    gh_oauth_input_properties        = local.secret_vars.gh-oauth.input-properties
    iohk_ghcr_creds_dockerconfigjson = local.secret_vars.iohk-ghcr-creds.dockerconfigjson
    iohk_ghcr_creds_input_properties = local.secret_vars.iohk-ghcr-creds.input-properties
  }
}
