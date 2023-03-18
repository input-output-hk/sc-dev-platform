include "root" {
  path = "${find_in_parent_folders()}"
}

locals {
  k8s = read_terragrunt_config(find_in_parent_folders("k8s-addons.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  dapps_namespaces = local.environment_vars.locals.namespaces
}

terraform {
  source = "../../../modules/grafana-operator"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_id              = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
  }
}

generate = local.k8s.generate

inputs = {
  # cluster-name = local.cluster
  cluster-name = dependency.eks.outputs.cluster_id
  namespace    = "grafana-operator"
  path_to_sops = "${get_repo_root()}/nix/metal/encrypted/grafana-agent-k8s-passwords.json"
  services_to_monitor = [
    {
      name = "db-sync",
      namespaces = local.dapps_namespaces
      app = "cardano-stack"
      port = "db-sync"
      path = "/"
    },
  ]
}
