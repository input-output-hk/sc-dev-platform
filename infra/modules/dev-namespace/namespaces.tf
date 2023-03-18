# This will create the desired Kubernetes namespaces, and give the users
# access to them
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(var.namespaces)

  metadata {
    labels = {
      name = each.value
    }
    name = each.value
  }
}

resource "kubernetes_role" "this" {
  for_each = toset(var.namespaces)
  metadata {
    namespace = each.value
    name = "dev-access"
    labels = {
      test = "tf-dev-access"
    }
  }

  rule {
    api_groups     = ["", "apps", "batch", "extensions"]
    resources      = [
      "configmaps",
      "cronjobs",
      "deployments",
      "events",
      "ingresses",
      "jobs",
      "pods",
      "pods/attach",
      "pods/exec",
      "pods/log",
      "pods/portforward",
      "secrets",
      "services"
    ]
    verbs          = ["get", "list", "watch", "create", "delete", "describe", "patch", "update"]
  }
}

resource "kubernetes_role_binding" "this" {
  for_each = toset(var.namespaces)
  metadata {
    namespace = each.value
    name      = "dev-access"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "dev-access"
  }
  subject {
    kind      = "User"
    name      = var.k8s_user
    api_group = "rbac.authorization.k8s.io"
    namespace = each.value
  }
}