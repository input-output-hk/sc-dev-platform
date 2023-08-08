resource "kubernetes_namespace" "vela-system" {
  metadata {
    labels = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "kubevela" {
  name       = "kubevela"

  repository = "https://charts.kubevela.net/core"
  chart      = "vela-core"
  version    = "1.8.0"
  namespace = kubernetes_namespace.vela-system.metadata[0].name
}
