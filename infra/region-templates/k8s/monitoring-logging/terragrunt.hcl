include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/particuleio/terraform-kubernetes-addons.git//modules/aws?ref=v10.3.0"
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
  domain  = local.account_vars.locals.domain
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_id              = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
  }
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    private_subnets_cidr_blocks = [
      "10.0.0.0/16",
      "192.168.0.0/24"
    ]
  }
}

generate = local.k8s.generate

inputs = {
  cluster-name = dependency.eks.outputs.cluster_id

  priority-class = {
    name = basename(get_terragrunt_dir())
  }

  priority-class-ds = {
    name = "${basename(get_terragrunt_dir())}-ds"
  }

  eks = {
    "cluster_oidc_issuer_url" = dependency.eks.outputs.cluster_oidc_issuer_url
  }

  loki-stack = {
    enabled              = false
    bucket_force_destroy = true
    extra_values         = <<-VALUES
      resources:
        requests:
          cpu: 1
          memory: 2Gi
        limits:
          cpu: 2
          memory: 4Gi
      loki:
        limits_config:
          ingestion_rate_mb: 320
          ingestion_burst_size_mb: 512
          max_streams_per_user: 100000
        chunk_store_config:
          max_look_back_period: 2160h
        table_manager:
          retention_deletes_enabled: true
          retention_period: 2160h
        storage:
          s3:
            region: ${local.region}
      ingress:
        enabled: true
        annotations:
          kubernetes.io/tls-acme: "true"
          nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
          nginx.ingress.kubernetes.io/auth-tls-secret: "telemetry/loki-ca"
        hosts:
          - logz.${local.domain}
        tls:
          - secretName: logz.${local.domain}
            hosts:
              - logz.${local.domain}
        VALUES
    bucket_lifecycle_rule = [
      {
        id      = "log"
        enabled = true
        transition = [
          {
            days          = 14
            storage_class = "INTELLIGENT_TIERING"
          },
        ]
        expiration = {
          days = 365
        }
      },
    ]
  }

  kube-prometheus-stack = {
    enabled                           = false
    thanos_create_iam_resources_irsa  = false
    allowed_cidrs                     = dependency.vpc.outputs.intra_subnets_cidr_blocks
    grafana_create_iam_resources_irsa = true
    extra_values                      = <<-EXTRA_VALUES
      grafana:
        enabled: true
        #grafana.ini:
        #  server:
        #    root_url: https://grafana.teleport.atalaprism.io
        #  auth.github:
        #   enabled: true
        #   allow_sign_up: true
        #   scopes: user:email,read:org
        #   auth_url: https://github.com/login/oauth/authorize
        #   token_url: https://github.com/login/oauth/access_token
        #   api_url: https://api.github.com/user
        #   team_ids: "7035997"
        #   allowed_organizations: "free-devops"
        #   # For testing purposes, can be specified later with secrets
        #   client_id: "d871676cef5f55d65796"
        #   client_secret: "1787cef44903a97e13d6ce65341e32b9a59aa945"
        #   role_attribute_path: "contains(groups[*], '@free-devops/test') && 'Editor' || 'Viewer'"
#          security:
#            disable_initial_admin_creation: true
#          auth:
#            disable_login_form: true
#          auth.anonymous:
#            enabled: true
#          org_name: Atala
        image:
          tag: 9.1.7
        deploymentStrategy:
          type: Recreate
        service:
          portName: service
        ingress:
          annotations:
            kubernetes.io/tls-acme: "true"
            kubernetes.io/ingress.class: alb
            alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
            alb.ingress.kubernetes.io/scheme: internet-facing
            alb.ingress.kubernetes.io/target-type: ip
            external-dns.alpha.kubernetes.io/hostname: telemetry.${local.domain}
        #ingressClassName: nginx
          enabled: true
          hosts:
            - telemetry.${local.domain}
          tls:
            - secretName: ${local.domain}
              hosts:
                - telemetry.${local.domain}
        persistence:
          enabled: true
          accessModes:
            - ReadWriteOnce
          size: 1Gi
      prometheus:
        prometheusSpec:
          nodeSelector:
            kubernetes.io/arch: amd64
          scrapeInterval: 60s
          retention: 2d
          retentionSize: "10GB"
          ruleSelectorNilUsesHelmValues: false
          serviceMonitorSelectorNilUsesHelmValues: false
          podMonitorSelectorNilUsesHelmValues: false
          probeSelectorNilUsesHelmValues: false
          storageSpec:
            volumeClaimTemplate:
              spec:
                accessModes: ["ReadWriteOnce"]
                resources:
                  requests:
                    storage: 10Gi
          resources:
            requests:
              cpu: 1
              memory: 2Gi
            limits:
              cpu: 2
              memory: 2Gi
      EXTRA_VALUES
  }

  promtail = {
    enabled = false
    wait    = false
  }

}
