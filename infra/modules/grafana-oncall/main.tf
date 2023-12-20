terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.41.0"
    }
  }
}

provider "grafana" {
  alias = "oncall"

  oncall_access_token = var.oncall_access_token
  oncall_url          = "https://oncall-prod-us-central-0.grafana.net/oncall"
}

# resource "grafana_team" "team" {
#   provider = grafana.oncall
# 
#   name    = var.team_name
#   email   = var.team_email
#   members = toset([for username, user in data.grafana_oncall_user.users : user.email])
# }
