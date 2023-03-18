resource "kubernetes_namespace" "this" {
  metadata {
    labels = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "grafana_agent_operator" {
  name       = "grafana-agent-operator"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana-agent-operator"
  namespace = kubernetes_namespace.this.metadata[0].name
}
