locals {

  externalsecrets = merge(
    local.helm_defaults,
    {
      name                 = local.helm_dependencies[index(local.helm_dependencies.*.name, "external-secrets")].name
      chart                = local.helm_dependencies[index(local.helm_dependencies.*.name, "external-secrets")].name
      repository           = local.helm_dependencies[index(local.helm_dependencies.*.name, "external-secrets")].repository
      chart_version        = local.helm_dependencies[index(local.helm_dependencies.*.name, "external-secrets")].version
      namespace            = var.namespace
      service_account_name = "externalsecrets"
      account_name         = var.account_name
      secret_prefix        = var.secret_prefix
      cluster-name         = var.cluster-name
      region               = var.region
      service_account_name = "externalsecrets"
      enabled              = var.enabled
    }
  )

  values_externalsecrets = <<VALUES
serviceAccount:
  name: ${local.externalsecrets["service_account_name"]}
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "${module.iam_assumable_role_externalsecrets[0].iam_role_arn}"
VALUES
}


module "iam_assumable_role_externalsecrets" {
  count = local.externalsecrets["enabled"] ? 1 : 0
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${local.externalsecrets["cluster-name"]}-externalsecrets"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.externalsecrets[0].arn]
  number_of_role_policy_arns    = 1
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.externalsecrets["namespace"]}:${local.externalsecrets["service_account_name"]}"]
}


resource "aws_iam_policy" "externalsecrets" {
  count = local.externalsecrets["enabled"] ? 1 : 0
  name   = "${local.externalsecrets["account_name"]}-${local.externalsecrets["cluster-name"]}-${local.externalsecrets["region"]}-externalsecrets"
  policy = data.aws_iam_policy_document.externalsecrets[0].json
}

data "aws_iam_policy_document" "externalsecrets" {
  count = local.externalsecrets["enabled"] ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "arn:aws:secretsmanager:${local.externalsecrets["region"]}:${var.aws_account_id}:secret:*-${local.externalsecrets["secret_prefix"]}",
      "arn:aws:secretsmanager:${local.externalsecrets["region"]}:${var.aws_account_id}:secret:${local.externalsecrets["secret_prefix"]}-*"
    ]
  }
}

resource "kubernetes_namespace" "externalsecrets" {
  count = local.externalsecrets["enabled"] ? 1 : 0

  metadata {
    labels = {
      name = local.externalsecrets["namespace"]
    }

    name = local.externalsecrets["namespace"]
  }
}

resource "helm_release" "externalsecrets" {
  count                 = local.externalsecrets["enabled"] ? 1 : 0
  repository            = local.externalsecrets["repository"]
  name                  = local.externalsecrets["name"]
  chart                 = local.externalsecrets["chart"]
  version               = local.externalsecrets["chart_version"]
  timeout               = local.externalsecrets["timeout"]
  force_update          = local.externalsecrets["force_update"]
  recreate_pods         = local.externalsecrets["recreate_pods"]
  wait                  = local.externalsecrets["wait"]
  atomic                = local.externalsecrets["atomic"]
  cleanup_on_fail       = local.externalsecrets["cleanup_on_fail"]
  dependency_update     = local.externalsecrets["dependency_update"]
  disable_crd_hooks     = local.externalsecrets["disable_crd_hooks"]
  disable_webhooks      = local.externalsecrets["disable_webhooks"]
  render_subchart_notes = local.externalsecrets["render_subchart_notes"]
  replace               = local.externalsecrets["replace"]
  reset_values          = local.externalsecrets["reset_values"]
  reuse_values          = local.externalsecrets["reuse_values"]
  skip_crds             = local.externalsecrets["skip_crds"]
  verify                = local.externalsecrets["verify"]
  values = [
    local.values_externalsecrets,
    local.externalsecrets["extra_values"]
  ]

  namespace = kubernetes_namespace.externalsecrets.*.metadata.0.name[count.index]

}

resource "kubectl_manifest" "externalsecrets_secretstore" {
  count = local.externalsecrets["enabled"] ? 1 : 0
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: "${local.externalsecrets["cluster-name"]}-externalsecrets"
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${local.externalsecrets["region"]}
YAML
}