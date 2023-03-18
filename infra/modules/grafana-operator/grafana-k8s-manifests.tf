# Create the Kubernetes secret used to connect to Grafana Cloud

provider "sops" {}

data "sops_file" "grafana_cloud_pass" {
  source_file = var.path_to_sops
}

data "kubectl_path_documents" "docs" {
  pattern = "grafana-agent-k8s.yaml.tmpl"
  sensitive_vars = {
    logs_username = data.sops_file.grafana_cloud_pass.data["logs-secret.username"],
    logs_password = data.sops_file.grafana_cloud_pass.data["logs-secret.password"],
    metrics_username = data.sops_file.grafana_cloud_pass.data["metrics-secret.username"],
    metrics_password = data.sops_file.grafana_cloud_pass.data["metrics-secret.password"],
  }
  vars = {
    namespace = var.namespace,
    cluster = var.cluster-name,
  }
}

# The custom resources provided by Grafana
resource "kubectl_manifest" "custom_resources" {
  count     = length(data.kubectl_path_documents.docs.documents)
  yaml_body = element(data.kubectl_path_documents.docs.documents, count.index)
  sensitive_fields = ["data", "stringData"]
  depends_on = [helm_release.grafana_agent_operator]
}
