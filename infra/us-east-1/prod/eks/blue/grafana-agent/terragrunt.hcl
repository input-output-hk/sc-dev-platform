locals {
  # Get provider configs
  providers        = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file("grafana-api-keys.enc.yaml"))
}

include "root" {
  path = find_in_parent_folders()
}

# Generate provider blocks
generate = local.providers.generate

terraform {
  source = "../../../../../modules/grafana-agent"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  grafana_agent = {
    values = [
      <<-EOT
    externalServices:
      prometheus:
        host: "https://prometheus-prod-13-prod-us-east-0.grafana.net/api/prom"
        basicAuth:
          username: "1296367"
          password: "somethingelse"

      loki:
        host: "https://logs-prod-006.grafana.net"
        basicAuth:
          username: "747229"
          password: "somethingelse"

      tempo:
        host: "https://tempo-prod-04-prod-us-east-0.grafana.net/tempo"
        basicAuth:
          username: "746333"
          password: "somethingelse"

    traces:
      enabled: true
      
    metrics:
      extraMetricRelabelingRules: |-
        rule {
          source_labels = ["namespace"]
          regex = "^$|marlowe|dapps-certification"
          action = "keep"
        }

    logs:
      pod_logs:
        namespaces: [
          - "marlowe-staging"
          - "marlowe-production"
          - "dapps-certification"
          - "dapps-certification-staging

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
    EOT
    ]
  }

}
