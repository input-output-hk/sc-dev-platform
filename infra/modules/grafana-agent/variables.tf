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

variable "grafana_tempo_api_key" {
  description = "API key for Grafana Cloud's Tempo service"
  type        = string
  sensitive   = true
}

variable "grafana_k8s_monitoring_api_key" {
  description = "API key for Grafana Cloud's K8s monitoring service"
  type        = string
  sensitive   = true
}

variable "grafana_tempo_username" {
  description = "Username for Grafana Cloud's Tempo service"
  type        = string
  sensitive   = true
}

variable "grafana_loki_username" {
  description = "Username for Grafana Cloud's Loki service"
  type        = string
  sensitive   = true
}

variable "grafana_prom_username" {
  description = "Username for Grafana Cloud's Prometheus service"
  type        = string
  sensitive   = true
}

variable "grafana_loki_host" {
  description = "Host endpoint for Grafana Cloudi's Loki service"
  type        = string
}

variable "grafana_prom_host" {
  description = "Host endpoint for Grafana Cloud's Prometheus service"
  type        = string
}

variable "grafana_tempo_host" {
  description = "Host endpoint for Grafana Cloud's Tempo service"
  type        = string
}


