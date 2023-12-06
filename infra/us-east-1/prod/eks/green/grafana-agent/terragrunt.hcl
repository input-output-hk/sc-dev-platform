locals {
  # Get provider configs
  providers        = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # Setting externalServices hosts
  prometheus_url = "https://prometheus-prod-13-prod-us-east-0.grafana.net"
  loki_url       = "https://logs-prod-006.grafana.net"
  tempo_url      = "tempo-prod-04-prod-us-east-0.grafana.net:443"

  # Extracting secrets from SOPS
  grafana_api_key     = local.secret_vars.grafana_cloud.api_key
  prometheus_username = local.secret_vars.grafana_cloud.prometheus_username
  tempo_username      = local.secret_vars.grafana_cloud.tempo_username
  loki_username       = local.secret_vars.grafana_cloud.loki_username
}

include "root" {
  path = find_in_parent_folders()
}

# Generate provider blocks
generate = local.providers.generate

terraform {
  source = "${get_repo_root()}/infra/modules/grafana-agent"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  grafana_agent = {
    values = [<<-EOT
    externalServices:
      prometheus:
        host: "${local.prometheus_url}"
        basicAuth:
          username: "${local.prometheus_username}"
          password: "${local.grafana_api_key}"
        writeRelabelConfigRules: |-
          write_relabel_config {
            source_labels = ["__name__"]
            regex = "traces_spanmetrics_latency_bucket|traces_service_graph_request_client_seconds_bucket|traces_service_graph_request_server_seconds_bucket"
            action = "drop"
          }

      loki:
        host: "${local.loki_url}"
        basicAuth:
          username: "${local.loki_username}"
          password: "${local.grafana_api_key}"

      tempo:
        host: "${local.tempo_url}"
        basicAuth:
          username: "${local.tempo_username}"
          password: "${local.grafana_api_key}"

    metrics:
      scrapeInterval: 60s
      kube-state-metrics:
        scrapeInterval: 60s
      node-exporter:
        scrapeInterval: 60s
      cost:
        enabled: false

    traces:
      enabled: true

    opencost:
      enabled: false

    logs:
      pod_logs:
        namespaces:
          - "marlowe-staging"
          - "marlowe-production"
          - "dapps-certification"
          - "dapps-certification-staging"

    grafana-agent:
      agent:
        extraPorts:
          - name: "otlp-grpc"
            port: 4317
            targetPort: 4317
            protocol: "TCP"
          - name: "otlp-http"
            port: 4318
            targetPort: 4318
            protocol: "TCP"
          - name: "zipkin"
            port: 9411
            targetPort: 9411
            protocol: "TCP"
    EOT
    ]
  }
}