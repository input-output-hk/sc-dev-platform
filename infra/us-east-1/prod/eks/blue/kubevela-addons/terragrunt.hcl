locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # Extract out common variables for reuse
  env               = local.environment_vars.locals.environment
  region            = local.environment_vars.locals.aws_region
  hostnames         = local.environment_vars.locals.hostnames
  profile           = local.account_vars.locals.aws_profile
  dex_client_id     = local.secret_vars.dex.clientID
  dex_client_secret = local.secret_vars.dex.clientSecret
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/input-output-hk/sc-dev-platform.git//infra/modules/kubevela-addons?ref=d12b6a69b4b0a95392eed1052c7fde653fbfbb71"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  aws_profile                        = local.profile
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_version                    = dependency.eks.outputs.cluster_version
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn
  velaux_domain                      = "vela.test.scdev.iohk.io"
  dex_client_id                      = local.dex_client_id
  dex_client_secret                  = local.dex_client_secret
}
