resource "kubernetes_manifest" "servicemonitor" {
  depends_on = [kubectl_manifest.custom_resources]
  for_each = {
    for entry in var.services_to_monitor : entry.name => entry
  }
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind = "ServiceMonitor"
    metadata = {
      name = "${each.value.name}-monitor"
      namespace = var.namespace
      labels = {
        instance = "primary"
      },
    }
    spec = {
      endpoints = [
        {
          interval = "60s",
          port = each.value.port,
          honorLabels = true,
          path = each.value.path
        }
      ],
      namespaceSelector = {
        matchNames = each.value.namespaces
      },
      selector = {
        matchLabels = {
          app = each.value.app
        }
      }
    }
  }
}
