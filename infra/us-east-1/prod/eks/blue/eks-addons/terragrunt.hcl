locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  domains     = local.environment_vars.locals.route53_config
  profile     = local.account_vars.locals.aws_profile
  secret_vars = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  route53_zone_arns = [for zone_id in values(local.domains) : "arn:aws:route53:::hostedzone/${zone_id}"]
  traefik_hostnames = [for domain in keys(local.domains) : "*.${domain}"]
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/input-output-hk/sc-dev-platform.git//infra/modules/eks/addons?ref=464f65bea1f574f26d58456701547a2aee31fa8c"
}

dependency "eks" {
  config_path = "../eks"
}

dependency "acm" {
  config_path = "../../../acm"
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
    enable_external_dns            = true
    external_dns_route53_zone_arns = local.route53_zone_arns
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
            namespacePolicy: All
            certificate:
              group: "core"
              kind: "Secret"
              name: "self-signed-tls"

        ports:
          web:
            redirectTo:
              port: websecure
              priority: 10

        service:
          annotations:
            "service.beta.kubernetes.io/aws-load-balancer-type": "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
            "service.beta.kubernetes.io/aws-load-balancer-name": "traefik"
            "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "ssl"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "${join(",", dependency.acm.outputs.acm_certificate_arns)}"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": "websecure"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy": "ELBSecurityPolicy-TLS13-1-2-2021-06"
            "external-dns.alpha.kubernetes.io/hostname": "${join(",", local.traefik_hostnames)}"
            "external-dns.alpha.kubernetes.io/aws-weight": "100"
            "external-dns.alpha.kubernetes.io/set-identifier": "traefik-blue"

        extraObjects:
          - apiVersion: v1
            data:
              tls.crt: ${local.secret_vars.traefik.tls_crt}
              tls.key: ${local.secret_vars.traefik.tls_key}
            kind: Secret
            metadata:
              name: self-signed-tls
              namespace: traefik
            type: kubernetes.io/tls 
        EOT
      ]
    }

    # KubeVela Controller
    enable_kubevela_controller = true
  }
}
