# Kubernetes resources to be deployed before EKS Addons

resource "kubectl_manifest" "letsencrypt_issuer" {
  yaml_body = file("${path.module}/letsencrypt_issuer.yaml")
}

data "kubectl_file_documents" "docs" {
  content = file("${path.module}/gateway_crds.yaml")
}

resource "kubectl_manifest" "gateway_crds" {
  for_each  = data.kubectl_file_documents.docs.manifests
  yaml_body = each.value
}
