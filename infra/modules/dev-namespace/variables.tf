variable "usernames" {
  description = "The list of users to create with access to to the Kubernetes namespaces being created"
  type = list(string)
}

variable "role_name" {
  description = "The name of the AWS role used to authenticate to the k8s cluster"
  type = string
}

variable "group_name" {
  description = "The name of the AWS group to create"
  type = string
}

variable "namespaces" {
  description = "The list of Kubernetes namespaces to create"
  type = list(string)
}

variable "k8s_user" {
  description = "The Kubernetes user to create in the RoleBinding"
  type = string
}

variable "cluster-name" {
  description = "Name of the Kubernetes cluster"
  default     = "sample-cluster"
  type        = string
}
