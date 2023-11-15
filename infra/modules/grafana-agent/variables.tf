variable "namespace" {
  description = "Set the namespace that grafana_agent is deployed to"
  type        = string
  default     = "grafana_agent"
}

variable "helm_defaults" {
  description = "Customize default Helm behavior"
  type        = any
  default     = {}
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample_cluster"
  type        = string
}

variable "grafana_password" {
  description = "password to grafana cloud"
  type        = string
  sensitive   = true
}

variable "grafana_tempo_username" {
  description = "username to grafana cloud for Tempo service"
  type        = string
}

variable "grafana_loki_username" {
  description = "username to grafana cloud for Loki service in k8s monitoring"
  type        = string
}

variable "grafana_prom_username" {
  description = "username to grafana cloud for Prometheus service in k8s monitoring"
  type        = string
}
