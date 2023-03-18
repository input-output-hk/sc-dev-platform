
locals {

  namespaces = var.namespaces
}

resource "kubernetes_namespace" "cardano_stack" {
  count = length(local.namespaces)

  metadata {
    labels = {
      name = local.namespaces[count.index]
    }

    name = local.namespaces[count.index]
  }
}

data "sops_file" "this" {
  source_file = var.path_to_sops
}

resource "kubernetes_secret" "dockerconfigjson" {
  count = length(local.namespaces)

  metadata {
    name = "dockerconfigjson"
    namespace = local.namespaces[count.index]
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "auth" = jsondecode(data.sops_file.this.raw).auths[var.registry_server].auth
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}
