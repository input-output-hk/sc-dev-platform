data "kubectl_file_documents" "postgres-operator" {
    content = file("${path.module}/postgres-operator.yaml")
}

resource "kubectl_manifest" "postgres-operator" {
    for_each  = data.kubectl_file_documents.postgres-operator.manifests
    yaml_body = each.value
}
