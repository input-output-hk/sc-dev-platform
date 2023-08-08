resource "helm_release" "cardano" {
  name       = "cardano"

  chart      = "./cardano"
  namespace = kubernetes_namespace.vela-system.metadata[0].name
}

