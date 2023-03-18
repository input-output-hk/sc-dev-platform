variable "namespace" {
  description = "Set the namespace to deploy the kubevela into"
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
