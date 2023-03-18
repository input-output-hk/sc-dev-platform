
locals {

  postgres_operator = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "postgres-operator")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "postgres-operator")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "postgres-operator")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "postgres-operator")].version
      namespace     = var.namespace
      enabled       = var.enabled
    }
  )
  values_postgres_operator = <<VALUES
  configKubernetes:
    enable_cross_namespace_secret: true
VALUES

}

resource "kubernetes_storage_class" "io2" {
  metadata {
    name = "io2"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = "true"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "io2"
    iops = "60000"
  }
}


resource "kubernetes_namespace" "postgres_operator" {
  count = local.postgres_operator["enabled"] ? 1 : 0

  metadata {
    labels = {
      name = local.postgres_operator["namespace"]
    }

    name = local.postgres_operator["namespace"]
  }
}

resource "helm_release" "postgres_operator" {
  count                 = local.postgres_operator["enabled"] ? 1 : 0
  repository            = local.postgres_operator["repository"]
  name                  = local.postgres_operator["name"]
  chart                 = local.postgres_operator["chart"]
  version               = local.postgres_operator["chart_version"]
  timeout               = local.postgres_operator["timeout"]
  force_update          = local.postgres_operator["force_update"]
  recreate_pods         = local.postgres_operator["recreate_pods"]
  wait                  = local.postgres_operator["wait"]
  atomic                = local.postgres_operator["atomic"]
  cleanup_on_fail       = local.postgres_operator["cleanup_on_fail"]
  dependency_update     = local.postgres_operator["dependency_update"]
  disable_crd_hooks     = local.postgres_operator["disable_crd_hooks"]
  disable_webhooks      = local.postgres_operator["disable_webhooks"]
  render_subchart_notes = local.postgres_operator["render_subchart_notes"]
  replace               = local.postgres_operator["replace"]
  reset_values          = local.postgres_operator["reset_values"]
  reuse_values          = local.postgres_operator["reuse_values"]
  skip_crds             = local.postgres_operator["skip_crds"]
  verify                = local.postgres_operator["verify"]
  values = [
    local.values_postgres_operator,
    local.postgres_operator["extra_values"]
  ]

  namespace = kubernetes_namespace.postgres_operator.*.metadata.0.name[count.index]

}
