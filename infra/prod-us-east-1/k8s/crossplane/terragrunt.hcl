include "root" {
  path = "${find_in_parent_folders()}"
}

locals {
  # Set kubernetes based providers
  k8s = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/k8s.hcl")
  helm = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/helm.hcl")

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  dapps_namespaces = local.environment_vars.locals.namespaces

}

terraform {
  source = "../../../modules/crossplane"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_id              = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
  }
}

generate = merge(local.k8s.generate, local.helm.generate)

inputs = {
  k8s-cluster-name = dependency.eks.outputs.cluster_id # for k8s provider

  eks_vpc_id = dependency.eks.outputs.cluster_id

  path_kubeconfig = "${get_parent_terragrunt_dir()}/kubeconfig-dapps-prod-us-east-1"
}
