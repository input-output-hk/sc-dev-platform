locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))
  grafana_oncall_access_token = local.secret_vars.grafana_cloud.grafana_oncall_access_token
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/infra/modules/grafana-oncall"
}

inputs = {
  oncall_access_token = local.grafana_oncall_access_token

  team_name  = "SCDE"
  team_email = "dev-empowerment@iohk.io"

  usernames = [
    "shealevy1",
    "renebarbosa",
    "olaniyioshunbote",
    "fentonhaslam",
    "oguzhanboran",
    "danielthagard",
    "lorenzocalegari",
    "rosariopulella"
  ]

  slack_channels = [
    "smart-contracts-dev-empowerment",
    "uptime",
    "sc-k8s-monitoring"
  ]

  oncall_schedule_start_date = "2023-12-18T00:00:00"
}
