module "grafana_agent" {

  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.chart
  chart_version    = local.chart_version
  repository       = local.repository
  description      = local.description
  namespace        = local.namespace
  create_namespace = local.create_namespace
  set              = local.grafana_agent.set
  values           = try(var.grafana_agent.values, local.grafana_agent.values)
  wait             = local.wait

}
