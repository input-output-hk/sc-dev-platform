resource "helm_release" "cardano" {
  count     = var.enable_cardano_nodes ? 1 : 0
  name      = "cardano"
  chart     = "./cardano"
  namespace = var.namespace
}

