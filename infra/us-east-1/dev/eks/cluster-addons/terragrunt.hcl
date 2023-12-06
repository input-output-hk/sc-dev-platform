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
      
    enable_nginx_ingress_load_balancer = true
    nginx_ingress_load_balancer = {
      name       = "nginx-public"
      values = [
        <<-EOT
        fullnameOverride: "nginx-public"
        nameOverride: "nginx-public"
        controller:
          ingressClassResource:
            enabled: true
            name: "nginx-public"
          service:
            annotations:
              "service.beta.kubernetes.io/aws-load-balancer-type": "external"
              "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
              "service.beta.kubernetes.io/aws-load-balancer-name": "dev-nginx-public"
              "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "tcp"
              "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
        EOT
      ]
    }

    enable_internal_nginx_ingress_load_balancer = true
    internal_nginx_ingress_load_balancer = {
      name       = "nginx-internal"
      values = [
        <<-EOT
        fullnameOverride: "nginx-internal"
        nameOverride: "nginx-internal"
        controller:
          ingressClassResource:
            enabled: true
            name: "nginx-internal"
          service:
            annotations:
              "meta.helm.sh/release-name": "nginx-internal"
              "service.beta.kubernetes.io/aws-load-balancer-type": "external"
              "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
              "service.beta.kubernetes.io/aws-load-balancer-name": "dev-nginx-internal"
              "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "tcp"
        EOT
      ]
    }
  }
}
