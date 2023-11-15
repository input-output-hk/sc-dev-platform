locals {
  # Get provider configs
  providers = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl")

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  grafana-password = local.secret_vars.grafana-api-key.secret
}

include "root" {
  path = find_in_parent_folders()
}

# Generate provider blocks
generate = local.providers.generate

terraform {
  source = "../../../../../modules/grafana-agent"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name           = dependency.eks.outputs.cluster_name
  namespace              = "grafana-agent"
  grafana_username       = "379443"
  grafana_loki_username  = "382930"
  grafana_prom_username  = "767922"
  grafana_tempo_username = "379443"
  grafana_password       = local.grafana-password
}
