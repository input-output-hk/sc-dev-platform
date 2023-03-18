
variable "namespaces" {
  description = "Namespaces to create and add required secrets"
  type        = list(string)
}

variable "cluster-name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample-cluster"
  type        = string
}

variable "registry_server" {
  description = "Registry URL"
  default     = "registry.ci.iog.io"
  type        = string
}

variable "path_to_sops" {
  description = "Path to the sops-encrypted file containing the grafana credentials"
  type        = string
}