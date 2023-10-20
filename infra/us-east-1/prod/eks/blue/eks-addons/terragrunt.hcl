locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env       = local.environment_vars.locals.environment
  region    = local.environment_vars.locals.aws_region
  hostnames = local.environment_vars.locals.hostnames
  profile   = local.account_vars.locals.aws_profile
 
  # Hosted Zone ARN for scdev-test.aws.iohkdev.io
  hostedzone_arn = "arn:aws:route53:::hostedzone//hostedzone/Z10147571DRRDCJXSER5Y"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/renebarbosafl/terraform-aws-eks.git//addons?ref=v0.0.3"
}

dependency "eks" {
  config_path = "../eks"
}

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

    # External-DNS
    enable_external_dns = true
    external_dns_route53_zone_arns = [local.hostedzone_arn]
    external_dns = {
      values = [
        <<-EOT
        env:
          # Don't change anything, useful for debugging purposes.
          - name: EXTERNAL_DNS_DRY_RUN
            value: "1"
        txtOwnerId: "${dependency.eks.outputs.cluster_name}"
        EOT
      ]
    }

    # Cert-Manager
    enable_cert_manager = true
    cert_manager = {
      values = [
        <<-EOT
        ingressShim:
          defaultIssuerName: letsencrypt
          defaultIssuerKind: ClusterIssuer
          defaultIssuerGroup: cert-manager.io
      
        extraArgs:
          - --feature-gates=ExperimentalGatewayAPISupport=true
        EOT
      ]
    }      

    # Traefik Load Balancer
    enable_traefik_load_balancer = true
    traefik_load_balancer = {
      values = [
        <<-EOT
        image:
          tag: "v3.0"

        experimental:
          kubernetesGateway:
            enabled: true

        ports:
          web:
            redirectTo: websecure

        service:
          annotations:
            "service.annotations.service.beta.kubernetes.io/aws-load-balancer-type": "external"
            "service.annotations.service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
            "service.annotations.service.beta.kubernetes.io/aws-load-balancer-name": "traefik"
            "service.annotations.service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
            "external-dns.alpha.kubernetes.io/hostname": "${join(",", local.hostnames)}"
            "external-dns.alpha.kubernetes.io/ttl": "60"
            "external-dns.alpha.kubernetes.io/aws-weight": "100"
        EOT
      ]
    }

    # KubeVela Controller
    enable_kubevela_controller = true
  }
}
