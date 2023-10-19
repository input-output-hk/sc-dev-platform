locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env       = local.environment_vars.locals.environment
  region    = local.environment_vars.locals.aws_region
  hostnames = local.environment_vars.locals.hostnames
  profile   = local.account_vars.locals.aws_profile
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/renebarbosafl/eks.git//cluster-addons?ref=v0.0.1"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name                       = "quick_brown_fox"
    cluster_version                    = "1.26"
    cluster_endpoint                   = "https://abcdef.gr7.us-east-1.eks.amazonaws.com"
    cluster_certificate_authority_data = "bGF6eS1icm93bi1mb3gK"
    oidc_provider_arn                  = "arn:aws:iam::677160962006:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/abcdef"
  }
}

inputs = {

  aws_profile                        = local.profile
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_version                    = dependency.eks.outputs.cluster_version
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn

  eks_addons = {
    enable_aws_load_balancer_controller = true
    enable_metrics_server               = true
    enable_cluster_autoscaler           = true
    cluster_autoscaler = {
      set = [{
        name  = "extraArgs.scale-down-utilization-threshold"
        value = "0.7"
      }]
    }
    enable_traefik_load_balancer = true
    traefik_load_balancer = {
      set = [{
        name  = "image.tag"
        value = "3.0"
        },
        {
          name  = "experimental.kubernetesGateway.enabled"
          value = true
        },
        {
          name  = "service.annotations.service\\.beta\\.kubernetes\\.io\\/aws-load-balancer-type"
          value = "external"
        },
        {
          name  = "service.annotations.service\\.beta\\.kubernetes\\.io\\/aws-load-balancer-nlb-target-type"
          value = "instance"
        },
        {
          name  = "service.annotations.service\\.beta\\.kubernetes\\.io\\/aws-load-balancer-name"
          value = "traefik"
        },
        {
          name  = "service.annotations.service\\.beta\\.kubernetes\\.io\\/aws-load-balancer-scheme"
          value = "internet-facing"
        },
        {
          name  = "service.annotations.external-dns.alpha\\.kubernetes\\/hostname"
          value = "${join(",", local.hostnames)}"
        },
        {
          name  = "ports.web.redirectTo"
          value = "websecure"
        }
      ]
    }
    enable_kubevela_controller = true
  }
}