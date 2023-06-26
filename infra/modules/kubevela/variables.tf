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

variable "cluster-name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample-cluster"
  type        = string
}

variable "addons" {
  description = "List of kubevela addons"
  type        = list(string)
  default     = []
}