include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "../../../modules/external-secrets"
}

locals {
  # Set kubernetes based providers
  k8s = read_terragrunt_config(find_in_parent_folders("k8s-addons.hcl"))
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  profile = local.account_vars.locals.aws_profile
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
  enabled                 = true
  cluster-name            = dependency.eks.outputs.cluster_id
  cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url
  namespace               = "externalsecrets"
  secret_prefix           = "prod"
  region                  = local.region
}
