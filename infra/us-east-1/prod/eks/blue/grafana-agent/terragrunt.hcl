include "root" {
  path = find_in_parent_folders()
}

locals {
  # Get provider configs
  k8s  = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/k8s.hcl")
  helm = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/helm.hcl")

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  dapps_namespaces = local.environment_vars.locals.namespaces

  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))
  grafana-password = local.secret_vars.grafana-api-key.secret
}

# Generate provider blocks
generate = merge(local.k8s.generate, local.helm.generate)

terraform {
  source = "../../../modules/grafana-agent"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name            = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
  }
}

inputs = {
  # cluster-name = local.cluster
  cluster-name     = dependency.eks.outputs.cluster_name
  k8s-cluster-name = dependency.eks.outputs.cluster_name # for provider block
  namespace        = "grafana-agent"
  grafana-username = "379443"
  grafana-password = local.grafana-password
}
