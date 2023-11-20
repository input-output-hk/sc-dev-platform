resource "kubernetes_namespace" "grafana-agent" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "grafana_agent" {
  repository = "https://grafana.github.io/helm-charts"
  name       = "grafana-agent"
  chart      = "grafana-agent"
  namespace  = var.namespace
  values = [<<-VALUES
    agent:
      mode: 'static'
      configMap:
        create: true
        content: |
          traces:
            configs:
            - name: default
              remote_write:
                - endpoint: ${var.grafana_tempo_host}
                  basic_auth:
                    username: ${var.grafana_tempo_username}
                    password: ${var.grafana_tempo_api_key}
              receivers:
                otlp:
                  protocols:
                    http:
                      cors:
                        allowed_origins:
                          - "http://*"
                          - "https://*"
      extraArgs:
        - -config.expand-env
      extraPorts:
        - name: otelhttp
          port: 4318
          targetPort: 4318
          protocol: "TCP"
  VALUES
  ]
}

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
        host: ${var.grafana_prom_host} 
        basicAuth:
          username: ${var.grafana_prom_username}
          password: ${var.grafana_k8s_monitoring_api_key}
      loki:
        host: ${var.grafana_loki_host} 
        basicAuth:
          username: ${var.grafana_loki_username}
          password: ${var.grafana_k8s_monitoring_api_key}
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

