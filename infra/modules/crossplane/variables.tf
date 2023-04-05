variable "path_kubeconfig" {
  description = "A path to a kube config file."
  type        = string
}

variable "eks_vpc_id" {
  description = "vpc of eks cluster"
  type        = string
}

variable "eks_subnet_ids" {
  description = "external subnet ids of eks cluster"
  type        = list(string)
}

variable "crossplane_namespace" {
  description = "Kubernetes namespace to install crossplane on"
  type = string
  default = "crossplane-system"
}
