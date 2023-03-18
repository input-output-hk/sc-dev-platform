locals {
  teleport-kube-agent = merge(
    local.helm_defaults,
    {
      name                      = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-kube-agent")].name
      chart                     = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-kube-agent")].name
      repository                = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-kube-agent")].repository
      chart_version             = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-kube-agent")].version
      namespace                 = "teleport-kube-agent"
      service_account_name      = "teleport-kube-agent"
      create_iam_resources_irsa = true
      enabled                   = false
      iam_policy_override       = null
      cluster-name              = var.cluster-name
      region                    = data.aws_region.current.name
      account_name              = data.aws_caller_identity.current.account_id
    },
    var.teleport-kube-agent
  )

  values_teleport-kube-agent = <<VALUES
VALUES
}

resource "kubernetes_namespace" "teleport-kube-agent" {
  count = local.teleport-kube-agent["enabled"] ? 1 : 0

  metadata {
    labels = {
      name = local.teleport-kube-agent["namespace"]
    }

    name = local.teleport-kube-agent["namespace"]
  }
}

resource "helm_release" "teleport-kube-agent" {
  count                 = local.teleport-kube-agent["enabled"] ? 1 : 0
  repository            = local.teleport-kube-agent["repository"]
  name                  = local.teleport-kube-agent["name"]
  chart                 = local.teleport-kube-agent["chart"]
  version               = local.teleport-kube-agent["chart_version"]
  timeout               = local.teleport-kube-agent["timeout"]
  force_update          = local.teleport-kube-agent["force_update"]
  recreate_pods         = local.teleport-kube-agent["recreate_pods"]
  wait                  = local.teleport-kube-agent["wait"]
  atomic                = local.teleport-kube-agent["atomic"]
  cleanup_on_fail       = local.teleport-kube-agent["cleanup_on_fail"]
  dependency_update     = local.teleport-kube-agent["dependency_update"]
  disable_crd_hooks     = local.teleport-kube-agent["disable_crd_hooks"]
  disable_webhooks      = local.teleport-kube-agent["disable_webhooks"]
  render_subchart_notes = local.teleport-kube-agent["render_subchart_notes"]
  replace               = local.teleport-kube-agent["replace"]
  reset_values          = local.teleport-kube-agent["reset_values"]
  reuse_values          = local.teleport-kube-agent["reuse_values"]
  skip_crds             = local.teleport-kube-agent["skip_crds"]
  verify                = local.teleport-kube-agent["verify"]
  values = [
    local.values_teleport-kube-agent,
    local.teleport-kube-agent["extra_values"]
  ]
  namespace = kubernetes_namespace.teleport-kube-agent.*.metadata.0.name[count.index]
}
