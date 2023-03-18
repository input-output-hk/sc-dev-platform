locals {
  teleport-cluster = merge(
    local.helm_defaults,
    {
      name                      = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-cluster")].name
      chart                     = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-cluster")].name
      repository                = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-cluster")].repository
      chart_version             = local.helm_dependencies[index(local.helm_dependencies.*.name, "teleport-cluster")].version
      namespace                 = "teleport-cluster"
      service_account_name      = "teleport-cluster"
      create_iam_resources_irsa = true
      enabled                   = false
      iam_policy_override       = null
      cluster-name              = var.cluster-name
      region                    = data.aws_region.current.name
      account_name              = data.aws_caller_identity.current.account_id
    },
    var.teleport-cluster
  )

  values_teleport-cluster = <<VALUES
chartMode: aws
clusterName: "${var.domain}"
aws:
  region: "${data.aws_region.current.id}"
  backendTable: "${var.cluster-name}-backend"
  auditLogTable: "${var.cluster-name}-events"
  auditLogMirrorOnStdout: false
  sessionRecordingBucket: "${var.cluster-name}-teleport"
  backups: true
  dynamoAutoScaling: false
highAvailability:
  replicaCount: 2
  certManager:
    enabled: true
    # Important to match cert-manager config
    issuerName: letsencrypt
    issuerKind: ClusterIssuer
    addCommonName: true
authentication:
  type: github
annotations:
  service:
    external-dns.alpha.kubernetes.io/hostname: "${var.domain},*.${var.domain}"
  serviceAccount:
    eks.amazonaws.com/role-arn: "${local.teleport-cluster["enabled"] && local.teleport-cluster["create_iam_resources_irsa"] ? module.iam_assumable_role_aws-teleport-cluster[0].iam_role_arn : ""}"
serviceAccount:
  create: true
  # The name of the ServiceAccount to use.
  # If not set and serviceAccount.create is true, the name is generated using the release name.
  # If create is false, the name will be used to reference an existing service account.
  name: "${local.teleport-cluster["service_account_name"]}"
VALUES
}

resource "kubernetes_namespace" "teleport-cluster" {
  count = local.teleport-cluster["enabled"] ? 1 : 0

  metadata {
    labels = {
      name = local.teleport-cluster["namespace"]
    }

    name = local.teleport-cluster["namespace"]
  }
}

resource "helm_release" "teleport-cluster" {
  count                 = local.teleport-cluster["enabled"] ? 1 : 0
  repository            = local.teleport-cluster["repository"]
  name                  = local.teleport-cluster["name"]
  chart                 = local.teleport-cluster["chart"]
  version               = local.teleport-cluster["chart_version"]
  timeout               = local.teleport-cluster["timeout"]
  force_update          = local.teleport-cluster["force_update"]
  recreate_pods         = local.teleport-cluster["recreate_pods"]
  wait                  = local.teleport-cluster["wait"]
  atomic                = local.teleport-cluster["atomic"]
  cleanup_on_fail       = local.teleport-cluster["cleanup_on_fail"]
  dependency_update     = local.teleport-cluster["dependency_update"]
  disable_crd_hooks     = local.teleport-cluster["disable_crd_hooks"]
  disable_webhooks      = local.teleport-cluster["disable_webhooks"]
  render_subchart_notes = local.teleport-cluster["render_subchart_notes"]
  replace               = local.teleport-cluster["replace"]
  reset_values          = local.teleport-cluster["reset_values"]
  reuse_values          = local.teleport-cluster["reuse_values"]
  skip_crds             = local.teleport-cluster["skip_crds"]
  verify                = local.teleport-cluster["verify"]
  values = [
    local.values_teleport-cluster,
    local.teleport-cluster["extra_values"]
  ]
  namespace = kubernetes_namespace.teleport-cluster.*.metadata.0.name[count.index]
}

module "iam_assumable_role_aws-teleport-cluster" {
  count                         = local.teleport-cluster["enabled"] && local.teleport-cluster["create_iam_resources_irsa"] ? 1 : 0
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${local.teleport-cluster["cluster-name"]}-teleport-cluster"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.teleport-cluster[0].arn]
  number_of_role_policy_arns    = 1
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.teleport-cluster["namespace"]}:${local.teleport-cluster["service_account_name"]}"]
}

resource "aws_iam_policy" "teleport-cluster" {
  count  = local.teleport-cluster["enabled"] && local.teleport-cluster["create_iam_resources_irsa"] ? 1 : 0
  name   = "${local.teleport-cluster["account_name"]}-${local.teleport-cluster["cluster-name"]}-${local.teleport-cluster["region"]}-teleport-cluster"
  policy = data.aws_iam_policy_document.teleport-cluster[0].json
}

data "aws_iam_policy_document" "teleport-cluster" {
  count = local.teleport-cluster["enabled"] && local.teleport-cluster["create_iam_resources_irsa"] ? 1 : 0
  statement {
    sid    = "ClusterStateStorage"
    effect = "Allow"
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DescribeStream",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:GetShardIterator",
      "dynamodb:GetItem",
      "dynamodb:UpdateTable",
      "dynamodb:GetRecords",
      "dynamodb:UpdateContinuousBackups"
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.cluster-name}-backend",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.cluster-name}-backend/stream/*"
    ]
  }

  statement {
    sid    = "ClusterEventsStorage"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:UpdateTable",
      "dynamodb:UpdateContinuousBackups"
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.cluster-name}-events",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.cluster-name}-events/index/*"
    ]
  }

  statement {
    sid    = "BucketActions"
    effect = "Allow"
    actions = [
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketVersioning",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketVersioning",
      "s3:CreateBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.cluster-name}-teleport"
    ]
  }

  statement {
    sid    = "ObjectActions"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectRetention",
      "s3:*Object",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::${var.cluster-name}-teleport/*"
    ]
  }
}
