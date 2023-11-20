locals {
  # Get provider configs
  providers = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl")

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file("grafana-api-keys.enc.yaml"))

  grafana-tempo-api-key          = local.secret_vars.grafana-tempo-api-key.secret
  grafana-k8s-monitoring-api-key = local.secret_vars.grafana-k8s-monitoring-api-key.secret
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

  grafana_loki_username  = "739886"
  grafana_prom_username  = "1281681"
  grafana_tempo_username = "738990"

  grafana_loki_host  = "https://logs-prod-006.grafana.net"
  grafana_prom_host  = "https://prometheus-prod-13-prod-us-east-0.grafana.net"
  grafana_tempo_host = "tempo-prod-04-prod-us-east-0.grafana.net:443"

  grafana_tempo_api_key          = local.grafana-tempo-api-key
  grafana_k8s_monitoring_api_key = local.grafana-k8s-monitoring-api-key
}
