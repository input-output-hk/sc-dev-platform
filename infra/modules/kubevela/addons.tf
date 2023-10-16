data "kubectl_file_documents" "postgres-operator" {
  content = file("${path.module}/postgres-operator.yaml")
}

resource "kubectl_manifest" "postgres-operator" {
  for_each  = data.kubectl_file_documents.postgres-operator.manifests
  yaml_body = each.value
}

data "kubectl_file_documents" "otel-operator" {
  content = file("${path.module}/otel-operator.yaml")
}

resource "kubectl_manifest" "otel-operator" {
  for_each  = data.kubectl_file_documents.otel-operator.manifests
  yaml_body = each.value
}
