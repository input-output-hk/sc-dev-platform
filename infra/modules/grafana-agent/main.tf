module "grafana_agent" {

  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.grafana_agent.chart
  chart_version    = try(var.grafana_agent.chart_version, local.grafana_agent.chart_version)
  repository       = try(var.grafana_agent.repository, local.grafana_agent.repository)
  description      = try(var.grafana_agent.description, local.grafana_agent.description)
  namespace        = try(var.grafana_agent.namespace, local.grafana_agent.namespace)
  create_namespace = try(var.grafana_agent.create_namespace, local.grafana_agent.create_namespace)
  values           = try(var.grafana_agent.values, local.grafana_agent.values)
  set              = try(var.grafana_agent.set, local.grafana_agent.set)
  wait             = try(var.grafana_agent.wait, local.grafana_agent.wait)

}
