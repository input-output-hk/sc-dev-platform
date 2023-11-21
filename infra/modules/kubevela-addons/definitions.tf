resource "kubernetes_manifest" "traitdefinition_https_route" {
  manifest = {
    "apiVersion" = "core.oam.dev/v1beta1"
    "kind"       = "TraitDefinition"
    "metadata" = {
      "annotations" = {
        "definition.oam.dev/description" = "defines HTTPS rules for mapping requests from a Gateway to Application."
      }
      "name"      = "https-route"
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
          "template" = file("${path.module}/definitions/https-route.cue")
        }
      }
    }
  }
}

resource "kubectl_manifest" "traitdefinition_resource" {
  force_new = true
  yaml_body = yamlencode({
    "apiVersion" = "core.oam.dev/v1beta1"
    "kind"       = "TraitDefinition"
    "metadata" = {
      "annotations" = {
        "definition.oam.dev/description" = "Add resource requests and limits on K8s pod for your workload which follows the pod spec in path 'spec.template."
      }
      "name"      = "resource"
      "namespace" = var.namespace
    }
    "spec" = {
      "appliesToWorkloads" = [
        "deployments.apps", "statefulsets.apps", "daemonsets.apps", "jobs.batch"
      ]
      "conflictsWith" = []
      "podDisruptive" = true
      "schematic" = {
        "cue" = {
          "template" = file("${path.module}/definitions/resource.cue")
        }
      }
    }
  })
}

resource "kubectl_manifest" "traitdefinition_database" {
  force_new = true
  yaml_body = yamlencode({
    "apiVersion" = "core.oam.dev/v1beta1"
    "kind"       = "TraitDefinition"
    "metadata" = {
      "annotations" = {
        "definition.oam.dev/description" = "Allow an Application to manage (or just use) a Postgres RDS instance"
      }
      "name"      = "database"
      "namespace" = var.namespace
    }
    "spec" = {
      "appliesToWorkloads" = [
        "deployments.apps", "statefulsets.apps", "daemonsets.apps", "jobs.batch"
      ]
      "conflictsWith" = []
      "podDisruptive" = true
      "schematic" = {
        "cue" = {
          "template" = templatefile("${path.module}/definitions/rds-instance.cue", {
            aws_region      = var.aws_region
            account_id      = var.account_id
            env             = var.env
            security_groups = var.rds_security_groups
          })
        }
      }
    }
  })
}

resource "kubectl_manifest" "workflowtdefinition_build_nix_image" {
  force_new = true
  yaml_body = yamlencode({
    "apiVersion" = "core.oam.dev/v1beta1"
    "kind"       = "WorkflowStepDefinition"
    "metadata" = {
      "annotations" = {
        "custom.definition.oam.dev/category" = "CI Integration"
        "definition.oam.dev/alias"           = ""
        "definition.oam.dev/description"     = "Build and push image with nix flake URIs"
      }
      "name"      = "build-nix-image"
      "namespace" = var.namespace
    }
    "spec" = {
      "schematic" = {
        "cue" = {
          "template" = file("${path.module}/definitions/build-nix-image.cue")
        }
      }
    }
  })
}

resource "kubectl_manifest" "componentdefinition_helmrelease" {
  force_new          = true
  yaml_body          = file("${path.module}/definitions/helm.yaml")
  override_namespace = var.namespace
}