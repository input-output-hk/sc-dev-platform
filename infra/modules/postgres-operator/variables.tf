variable "enabled" {
  description = "Switch to enable or disable"
  type        = bool
  default     = "false"
}

variable "namespace" {
  description = "Set the namesapce to deploy argocd into"
  type        = string
  default     = "postgres-operator"
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