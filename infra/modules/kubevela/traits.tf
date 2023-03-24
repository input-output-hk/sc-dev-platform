resource "kubernetes_manifest" "traitdefinition_https_route" {
  manifest = {
    "apiVersion" = "core.oam.dev/v1beta1"
    "kind" = "TraitDefinition"
    "metadata" = {
      "annotations" = {
        "definition.oam.dev/description" = "defines HTTPS rules for mapping requests from a Gateway to Application."
      }
      "name" = "https-route"
      "namespace" = var.namespace
    }
    "spec" = {
      "appliesToWorkloads" = [
        "*",
      ]
      "conflictsWith" = []
      "podDisruptive" = false
      "schematic" = {
        "cue" = {
          "template" = file("${path.module}/https-route.cue")
        }
      }
    }
  }
}

resource "kubernetes_manifest" "traitdefinition_http_route" {
  manifest = {
    "apiVersion" = "core.oam.dev/v1beta1"
    "kind" = "TraitDefinition"
    "metadata" = {
      "annotations" = {
        "definition.oam.dev/description" = "defines HTTP rules for mapping requests from a Gateway to Application."
      }
      "name" = "http-route"
      "namespace" = var.namespace
    }
    "spec" = {
      "appliesToWorkloads" = [
        "*",
      ]
      "conflictsWith" = []
      "podDisruptive" = false
      "schematic" = {
        "cue" = {
          "template" = file("${path.module}/http-route.cue")
        }
      }
    }
  }
}
