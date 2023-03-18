locals {
  clusters = [ "dapps-prod-us-east-1", "dapps-prod-eu-central-1" ]
  namespaces = [ "preview-prod", "preprod-prod", "mainnet-prod" ]

  cluster_namespaces = distinct(flatten([
    for cluster in local.clusters : [
      for namespace in local.namespaces : {
        namespace = namespace
        cluster    = cluster
      }
    ]
  ]))
}

resource "grafana_folder" "dapps_environments" {
  provider = grafana.second
  title = "Dapps Environments"
}

resource "grafana_dashboard" "dapps_environment" {
  provider = grafana.second

  for_each = {
    for entry in local.cluster_namespaces : "${entry.cluster}_${entry.namespace}" => entry 
  }
  
  # config_json = templatefile("${path.module}/dashboards/dapps-env-dashboard.json", {
  #   cluster   = each.value.cluster
  #   namespace = each.value.namespace
  #   uid = each.key
  # })
  # folder      = grafana_folder.dapps_environments.id
}
