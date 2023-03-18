resource "kubernetes_namespace" "vela-system" {
  metadata {
    labels = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "kubernetes_manifest" "application_vela_system_traefik" {
  manifest = {
    apiVersion = "core.oam.dev/v1beta1"
    kind = "Application"
    metadata = {
      name = "traefik"
      namespace = kubernetes_namespace.vela-system.metadata[0].name
    }
    spec = {
      components = [
        {
          name = "traefik"
          type = "helm"
          properties = {
            chart = "traefik"
            repoType = "helm"
            url = "https://charts.kubevela.net/community"
            version = "10.19.4"
            values = {
              experimental = {
                kubernetesGateway = {
                  enabled = true
                  namespacePolicy = "All"
                }
              }
              logs = {
                access = {
                  enabled = true
                }
              }
              ports = {
                traefik = {
                  expose = true
                }
              }
              service = {
                type = "LoadBalancer"
              }
            }
          }
        },
      ]
    }
  }
}
