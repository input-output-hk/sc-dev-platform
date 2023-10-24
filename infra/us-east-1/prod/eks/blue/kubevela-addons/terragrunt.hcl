include "root" {
  path = find_in_parent_folders()
}

locals {
  # Get provider configs
  k8s     = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/k8s.hcl")
  helm    = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/helm.hcl")
  kubectl = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/kubectl.hcl")

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  dapps_namespaces = local.environment_vars.locals.namespaces
}

# Generate provider blocks
generate = merge(local.k8s.generate, local.helm.generate, local.kubectl.generate)

terraform {
  source = "../../../modules/kubevela-addons"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_id              = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
  }
}

dependency "kubevela" {
  config_path = "../kubevela"
}

inputs = {
  # cluster-name = local.cluster
  cluster-name     = dependency.eks.outputs.cluster_name
  k8s-cluster-name = dependency.eks.outputs.cluster_name # for provider block
  namespace        = dependency.kubevela.outputs.namespace
}
