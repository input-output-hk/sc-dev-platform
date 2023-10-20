variable "namespace" {
  description = "Set the namespace that kubevela is deployed to"
  type        = string
  default     = "vela-system"
}

variable "helm_defaults" {
  description = "Customize default Helm behavior"
  type        = any
  default     = {}
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample-cluster"
  type        = string
}

variable "velaux_domain" {
  description = "domain where VelaUX will be hosted"
  type        = string
}

variable "dex_client_id" {
  description = "client ID for dex provider"
  type        = string
  sensitive   = true
}

variable "dex_client_secret" {
  description = "client secret for dex provider"
  type        = string
  sensitive   = true
}
