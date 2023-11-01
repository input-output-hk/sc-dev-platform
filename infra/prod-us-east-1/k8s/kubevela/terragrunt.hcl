include "root" {
  path = "${find_in_parent_folders()}"
}

locals {
  # Get provider configs
  providers = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl")

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  dapps_namespaces = local.environment_vars.locals.namespaces
  vela_namespace   = "vela-system"
}

# Generate provider blocks
generate = local.providers.generate

terraform {
  source = "../../../modules/kubevela"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster-name     = dependency.eks.outputs.cluster_id
  k8s-cluster-name = dependency.eks.outputs.cluster_id # for provider block
  namespace        = local.vela_namespace
}
