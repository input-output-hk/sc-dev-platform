resource "grafana_oncall_on_call_shift" "week_shift" {
  provider = grafana.oncall

  name       = "${var.team_name} Week Shift"
  type       = "rolling_users"
  start      = var.oncall_schedule_start_date
  time_zone  = "UTC"
  duration   = 60 * 60 * 24 // 24 hours
  frequency  = "weekly"
  interval   = 1
  by_day     = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
  week_start = "MO"

  rolling_users = [for username, user in data.grafana_oncall_user.users : [user.id]]
  start_rotation_from_user_index = 1
}

resource "grafana_oncall_schedule" "team_schedule" {
 provider  = grafana.oncall

 name      = "${var.team_name} Calendar Schedule"
 type      = "calendar"
 time_zone = "UTC"
 shifts    = [
   grafana_oncall_on_call_shift.week_shift.id
 ]
}
