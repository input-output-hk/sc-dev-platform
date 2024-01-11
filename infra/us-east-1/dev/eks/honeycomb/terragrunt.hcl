locals {
  # Get provider configs
  providers        = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # Extracting secrets from SOPS
  honeycomb_api_key = local.secret_vars.honeycomb.api_key
}

include "root" {
  path = find_in_parent_folders()
}

# Generate provider blocks
generate = local.providers.generate

terraform {
  source = "${get_repo_root()}/infra/modules/honeycomb"
}

dependency "eks" {
  config_path = "../cluster"
}

inputs = {
  cluster_name      = "${dependency.eks.outputs.cluster_name}"
  honeycomb_api_key = local.honeycomb_api_key
}
