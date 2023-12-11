locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
<<<<<<< HEAD
=======
  domains     = local.environment_vars.locals.route53_config
>>>>>>> 9ba4b35 (PLT-8878 (#65))
  profile     = local.account_vars.locals.aws_profile
  secret_vars = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # Generators
  providers = read_terragrunt_config(find_in_parent_folders("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl"))
<<<<<<< HEAD
=======

  route53_zone_arns = [for zone_id in values(local.domains) : "arn:aws:route53:::hostedzone/${zone_id}"]
  traefik_hostnames = [for domain in keys(local.domains) : "*.${domain}"]
>>>>>>> 9ba4b35 (PLT-8878 (#65))
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/infra/modules/eks/addons"
}

dependency "eks" {
  config_path = "../eks"
}

dependency "acm" {
  config_path = "../../../acm"
}

<<<<<<< HEAD
dependency "route53" {
  config_path = "${get_repo_root()}/infra/global/route53/zones"
}

=======
>>>>>>> 9ba4b35 (PLT-8878 (#65))
generate = local.providers.generate

inputs = {

  aws_profile                        = local.profile
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_version                    = dependency.eks.outputs.cluster_version
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn

  eks_addons = {
    # Disable Gateway-API System 
    enable_gateway_system = false
    
    # Cluster Autoscaler
    cluster_autoscaler = {
      set = [{
        name  = "extraArgs.scale-down-utilization-threshold"
        value = "0.7"
      }]
    }

    # External-DNS
    enable_external_dns            = true
<<<<<<< HEAD
    external_dns_route53_zone_arns = values(dependency.route53.outputs.route53_zone_zone_arn)
=======
    external_dns_route53_zone_arns = local.route53_zone_arns
>>>>>>> 9ba4b35 (PLT-8878 (#65))
    external_dns = {
      values = [
        <<-EOT
        env:
          # Don't change anything, useful for debugging purposes.
          - name: EXTERNAL_DNS_DRY_RUN
            value: "0"
        txtOwnerId: "${dependency.eks.outputs.cluster_name}"
        EOT
      ]
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
            controllerValue: "k8s.io/ingress-nginx-public"
          service:
            annotations:
              "service.beta.kubernetes.io/aws-load-balancer-type": "external"
              "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
              "service.beta.kubernetes.io/aws-load-balancer-name": "prod-green-nginx-public"
              "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "ssl"
              "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
              "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "${join(",", dependency.acm.outputs.acm_certificate_arns)}"
              "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": "https"
              "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy": "ELBSecurityPolicy-TLS13-1-2-2021-06"
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
            controllerValue: "k8s.io/ingress-nginx-internal"
          service:
            annotations:
              "meta.helm.sh/release-name": "nginx-internal"
              "service.beta.kubernetes.io/aws-load-balancer-type": "external"
              "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
              "service.beta.kubernetes.io/aws-load-balancer-name": "prod-green-nginx-internal"
              "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "ssl"
              "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "${join(",", dependency.acm.outputs.acm_certificate_arns)}"
              "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": "https"
              "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy": "ELBSecurityPolicy-TLS13-1-2-2021-06"
        EOT
      ]
    }
    # KubeVela Controller
    enable_kubevela_controller = true
  }
}
