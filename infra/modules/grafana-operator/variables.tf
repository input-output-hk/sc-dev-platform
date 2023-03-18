variable "namespace" {
  description = "Set the namespace to deploy the Grafana Operator into"
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

variable "path_to_sops" {
  description = "Path to the sops-encrypted file containing the grafana credentials"
  type        = string
}

variable "services_to_monitor" {
  description = "The services to monitor. Each element contains a name, a list of namespaces, a selector label, a port, and a metrics endpoint"
  type = list
}