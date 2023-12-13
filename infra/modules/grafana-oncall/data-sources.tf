# ===================================== #
# USERS
# ===================================== #

data "grafana_oncall_user" "users" {
  provider = grafana.oncall

  for_each = toset(var.usernames)
  username = each.value
}

# ============================================== #
# CHANNELS
# ============================================== #

data "grafana_oncall_slack_channel" "slack_channels" {
  provider = grafana.oncall

  for_each = toset(var.slack_channels)
  name     = each.value
}

# ============================================== #
# TEAMS
# ============================================== #

data "grafana_oncall_team" "team" {
  provider = grafana.oncall

  name = var.team_name
}
