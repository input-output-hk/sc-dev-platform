variable "oncall_access_token" {
  description = "Access token for Grafana Oncall system"
  type        = string
  sensitive   = true
}

variable "usernames" {
  description = "List of users in the Oncall schedule"
  type        = list(string)
  default     = [ ]
}

variable "team_name" {
  description = "Name of team using the oncall schedule"
  type        = string
}

variable "team_email" {
  description = "Email address of team using the oncall schedule"
  type        = string
}

variable "slack_channels" {
  description = "List of Slack channels notifications/alerts will be sent to"
  type        = list(string)
  default     = [ ]
}

variable "oncall_schedule_start_date" {
  description = "Start date and time for oncall schedule"
  type        = string
}
