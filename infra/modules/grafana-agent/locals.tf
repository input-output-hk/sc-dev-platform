locals {
  grafana_agent = {
    chart            = "k8s-monitoring-helm"
    chart_version    = "0.5.1"
    repository       = "https://grafana.github.io/helm-charts"
    description      = "A Helm chart for gathering, scraping, and forwarding Kubernetes infrastructure metrics and logs to a Grafana Stack."
    namespace        = "grafana-agent"
    create_namespace = true
    wait             = false
    set = [{
      name  = "cluster.name"
      value = var.cluster_name
    }]
    values = []
  }
}