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
  validation {
    condition     = can(regex("^[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-3]:[0-5][0-9]:[0-5][0-9]$", var.oncall_schedule_start_date))
    error_message = "The oncall schedule start date must be a string in the format YYYY-MM-DDTHH:MM:SS e.g. '2025-09-17T13:46:28'."
  }
}
