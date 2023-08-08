variable "namespace" {
  description = "Set the namespace that grafana-agent is deployed to"
  type        = string
  default     = "grafana-agent"
}

variable "helm_defaults" {
  description = "Customize default Helm behavior"
  type        = any
  default     = {}
}

variable "cluster-name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample-cluster"
  type        = string
}

variable "grafana-password" {
  description = "password to grafana cloud"
  type = string
  sensitive = true
}

variable "grafana-username" {
  description = "username to grafana cloud"
  type = string
}
