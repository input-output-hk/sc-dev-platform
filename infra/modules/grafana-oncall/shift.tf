resource "grafana_oncall_on_call_shift" "week_shift" {
  provider = grafana.oncall

  name       = "${var.team_name} Week Shift"
  type       = "rolling_users"
  start      = "2023-12-18T00:00:00"
  duration   = 60 * 60 * 24 // 24 hours
  frequency  = "weekly"
  interval   = 2
  by_day     = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
  week_start = "MO"
  rolling_users = [for username, user in data.grafana_oncall_user.users : [user.id]]
  time_zone = "UTC"
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
