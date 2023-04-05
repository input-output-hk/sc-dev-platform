include "root" {
  path = "${find_in_parent_folders()}"
}

locals {
  # Set kubernetes based providers
  k8s = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/k8s.hcl")
  helm = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/helm.hcl")

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  dapps_namespaces = local.environment_vars.locals.namespaces

  # Can't use aws ecrpublic data source, https://github.com/gruntwork-io/terragrunt/issues/1150
  # So manually retrieving with aws cli
  ecrpublic_username = "AWS"
  ecrpublic_token = run_cmd("--terragrunt-quiet", "aws", "ecr-public", "get-login-password")
}

terraform {
  source = "github.com/aws-ia/terraform-aws-eks-ack-addons//.?ref=v1.3.0"
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
  cluster_id = dependency.eks.outputs.cluster_id
  k8s-cluster-name = dependency.eks.outputs.cluster_id # for k8s provider

  ecrpublic_username = local.ecrpublic_username
  ecrpublic_token    = local.ecrpublic_token

  data_plane_wait_arn = dependency.eks.outputs.cluster_security_group_arn

  enable_rds = true
}
