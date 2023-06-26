data "kubectl_file_documents" "postgres-operator" {
    content = file("${path.module}/addons/postgres-operator.yaml")
}

resource "kubectl_manifest" "postgres-operator" {
    for_each  = data.kubectl_file_documents.postgres-operator.manifests
    yaml_body = each.value
}

# data "kubectl_file_documents" "addon" {
#   for_each = {
#     for addon in var.addons : addon.name => addon
#   }
#   content = file("${path.module}/addons/${each.value}.yaml")
# }

# resource "kubectl_manifest" "addon" {
#   for_each  = data.kubectl_file_documents.addon.manifests
#   yaml_body = each.value
# }
