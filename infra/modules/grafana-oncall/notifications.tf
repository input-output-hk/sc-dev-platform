resource "grafana_oncall_integration" "alertmanager" {
  provider = grafana.oncall

  name = "${var.team_name} AlertManager"
  type = "alertmanager"
  default_route {
    escalation_chain_id = grafana_oncall_escalation_chain.team_escalation_chain.id
  }
}

resource "grafana_oncall_route" "team_route" {
  provider = grafana.oncall

  integration_id      = grafana_oncall_integration.alertmanager.id
  escalation_chain_id = grafana_oncall_escalation_chain.team_escalation_chain.id
  routing_regex       = "\"severity\": \"critical\""
  position            = 0
}

resource "grafana_oncall_escalation_chain" "team_escalation_chain" {
  provider = grafana.oncall

  name = "${var.team_name} Escalation Chain"
}

# Notify users from on-call schedule
resource "grafana_oncall_escalation" "team_notify_schedule_step" {
  provider = grafana.oncall

  escalation_chain_id          = grafana_oncall_escalation_chain.team_escalation_chain.id
  type                         = "notify_on_call_from_schedule"
  notify_on_call_from_schedule = grafana_oncall_schedule.team_schedule.id
  position                     = 0
}

# Wait step for 5 Minutes
resource "grafana_oncall_escalation" "team_wait_step" {
  provider = grafana.oncall

  escalation_chain_id = grafana_oncall_escalation_chain.team_escalation_chain.id
  type                = "wait"
  duration            = 300
  position            = 1
}

# Notify default Slack channel step
resource "grafana_oncall_escalation" "team_notify_step" {
  provider = grafana.oncall

  escalation_chain_id = grafana_oncall_escalation_chain.team_escalation_chain.id
  type                = "notify_whole_channel"
  important           = true
  position            = 2
}
