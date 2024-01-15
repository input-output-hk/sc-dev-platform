locals {
  chart            = "opentelemetry-collector"
  chart_version    = "0.78.0"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  description      = "OpenTelemetry Collector Helm chart for Kubernetes"
  namespace        = "honeycomb"
  create_namespace = true
  wait             = false

}
