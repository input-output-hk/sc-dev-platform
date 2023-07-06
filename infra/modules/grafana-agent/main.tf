resource "kubernetes_namespace" "grafana-agent" {
  metadata {
    name = "grafana-agent"
  }
}

resource "kubernetes_secret" "grafana-password" {
  metadata {
    name = "grafana-password"
    namespace = kubernetes_namespace.grafana-agent.metadata[0].name
  }

  data = {
    GRAFANA_PASSWORD = var.grafana-password
  }
}

resource "helm_release" "grafana_agent" {
  repository = "https://grafana.github.io/helm-charts"
  name = "grafana-agent"
  chart = "grafana-agent"
  namespace = kubernetes_namespace.grafana-agent.metadata[0].name
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
                    username: ${var.grafana-username}
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
