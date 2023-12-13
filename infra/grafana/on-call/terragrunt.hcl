locals {
  # Get provider configs
  providers        = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/providers.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  grafana_oncall_access_token = local.secret_vars.grafana_cloud.grafana_oncall_access_token
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/grafana-oncall"
}

inputs = {
  oncall_access_token = local.grafana_oncall_access_token

  team_name  = "SCDE"
  team_email = "dev-empowerment@iohk.io"

  usernames = [
    "olaniyioshunbote",
    "renebarbosa",
    "oguzhanboran",
    "danielthagard",
    "shealevy1"
  ]

  slack_channels = [
    "smart-contracts-dev-empowerment",
    "uptime",
    "sc-k8s-monitoring"
  ]
}
