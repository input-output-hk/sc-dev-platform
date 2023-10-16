resource "helm_release" "cardano" {
  name = "cardano"

  chart     = "./cardano"
  namespace = var.namespace
}

