locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  profile     = local.account_vars.locals.aws_profile

  # Generators
  providers = read_terragrunt_config(find_in_parent_folders("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl"))
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../../infra/modules/eks/addons"
}

dependency "eks" {
  config_path = "../cluster"
}

generate = local.providers.generate

inputs = {

  aws_profile                        = local.profile
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_version                    = dependency.eks.outputs.cluster_version
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn

  eks_addons = {

    # Cluster Autoscaler
    cluster_autoscaler = {
      set = [{
        name  = "extraArgs.scale-down-utilization-threshold"
        value = "0.7"
      }]
    }

  }
}
