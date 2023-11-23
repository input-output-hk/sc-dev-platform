/*
resource "helm_release" "grafana-k8s-monitoring" {
  name       = "grafana-k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  version    = "0.1.4"
  namespace  = var.namespace

  values = [<<-VALUES
    cluster:
      name: ${var.cluster_name}
    externalServices:
      prometheus:
        host: https://prometheus-us-central1.grafana.net
        basicAuth:
          username: ${var.grafana_prom_username}
          password: ${data.kubernetes_secret.api_key_secret.data["GRAFANA_PASSWORD"]}
      loki:
        host: https://logs-prod-017.grafana.net
        basicAuth:
          username: ${var.grafana_loki_username}
          password: ${data.kubernetes_secret.api_key_secret.data["GRAFANA_PASSWORD"]}
    metrics:
      cost:
        enabled: false
      podMonitors:
        namespaces:
          - "marlowe-staging"
          - "marlowe-production"
          - "dapps-certification-staging"
          - "dapps-certification"
      probes:
        namespaces:
          - "marlowe-staging"
          - "marlowe-production"
          - "dapps-certification-staging"
          - "dapps-certification"
      serviceMonitors:
        namespaces:
          - "marlowe-staging"
          - "marlowe-production"
          - "dapps-certification-staging"
          - "dapps-certification"
    opencost:
      enabled: false 
    crds:
      create: false
    logs:
      pod_logs:
        namespaces:
          - "marlowe-staging"
          - "marlowe-production"
          - "dapps-certification-staging"
          - "dapps-certification"
      cluster_events:
        namespaces:
          - "marlowe-staging"
          - "marlowe-production"
          - "dapps-certification-staging"
          - "dapps-certification"
  VALUES
  ]
}
*/

module "grafana_agent" {

  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.grafana_agent.chart
  chart_version    = try(var.grafana_agent.chart_version, local.grafana_agent.chart_version)
  repository       = try(var.grafana_agent.repository, local.grafana_agent.repository)
  description      = try(var.grafana_agent.description, local.grafana_agent.description)
  namespace        = try(var.grafana_agent.namespace, local.grafana_agent.namespace)
  create_namespace = try(var.grafana_agent.create_namespace, local.grafana_agent.create_namespace)
  values           = try(var.grafana_agent.values, local.grafana_agent.values)
  set              = try(var.grafana_agent.set, local.grafana_agent.set)
  wait             = try(var.grafana_agent.wait, local.grafana_agent.wait)

}
