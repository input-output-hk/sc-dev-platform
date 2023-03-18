variable "path_to_sops" {
  description = "Path to the sops-encrypted file containing the grafana credentials"
  type        = string
}

variable "stack_name" {
  type = string
  description = "Name of the Grafana Cloud stack to create"
}

variable "region" {
  type = string
  default = "eu"
  description = "Region to host the Grafana stack"
}
