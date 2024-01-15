resource "kubernetes_secret" "honeycomb_api_key" {
  metadata {
    name      = "honeycomb"
    namespace = module.honeycomb_deployment.namespace
  }
  data = {
    api-key = var.honeycomb_api_key # base64 encoded value of "mykey"
  }
  type = "Opaque"
}

module "honeycomb_deployment" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  name = "honeycomb-deployment"

  chart            = local.chart
  chart_version    = local.chart_version
  repository       = local.repository
  description      = local.description
  namespace        = local.namespace
  create_namespace = local.create_namespace
  values = [
    file("${path.module}/values-deployment.yaml")
  ]
  wait = local.wait
}


module "honeycomb_daemonset" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  name = "honeycomb-daemonset"

  chart            = local.chart
  chart_version    = local.chart_version
  repository       = local.repository
  description      = local.description
  namespace        = local.namespace
  create_namespace = local.create_namespace
  values = [
    file("${path.module}/values-daemonset.yaml")
  ]
  wait = local.wait
}

