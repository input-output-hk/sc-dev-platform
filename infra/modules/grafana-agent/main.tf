resource "kubernetes_namespace" "grafana-agent" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "grafana-password" {
  metadata {
    name = "grafana-password"
    namespace = var.namespace
  }

  data = {
    GRAFANA_PASSWORD = var.grafana-password
  }
}

resource "helm_release" "grafana_agent" {
  repository = "https://grafana.github.io/helm-charts"
  name = "grafana-agent"
  chart = "grafana-agent"
  namespace = var.namespace
  values = [ <<-VALUES
    agent:
      mode: 'static'
      configMap:
        create: true
        content: |
          traces:
            configs:
            - name: default
              remote_write:
                - endpoint: tempo-us-central1.grafana.net:443
                  basic_auth:
                    username: ${var.grafana-tempo-username}
                    password: $${GRAFANA_PASSWORD}
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
      envFrom:
        - secretRef:
            name: grafana-password
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

  values = [ <<-VALUES
    cluster:
      name: dapps-prod-us-east-1
    externalServices:
      prometheus:
        host: https://prometheus-us-central1.grafana.net
        basicAuth:
          username: ${var.grafana-prom-username}
          password: ${data.kubernetes_secret.api_key_secret.data["GRAFANA_PASSWORD"]}
      loki:
        host: https://logs-prod-017.grafana.net
        basicAuth:
          username: ${var.grafana-loki-username}
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

data "kubernetes_secret" "api_key_secret" {
  metadata {
    name      = "grafana-k8s-password"
    namespace = var.namespace
  }
}

