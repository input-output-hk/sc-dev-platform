variable "helm_defaults" {
  description = "Customize default Helm behavior"
  type        = any
  default     = {}
}

variable "teleport-cluster" {
  description = "Customize teleport-cluster chart, see `teleport-cluster.tf` for supported values"
  type        = any
  default     = {}
}

variable "teleport-kube-agent" {
  description = "Customize teleport-kube-agent chart, see `teleport-kube-agent.tf` for supported values"
  type        = any
  default     = {}
}

variable "cluster-name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample-cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "EKS cluster oidc issuer url"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
  default     = "teleport.atalaprism.io"
}
