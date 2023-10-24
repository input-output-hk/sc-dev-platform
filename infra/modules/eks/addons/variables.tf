variable "aws_profile" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority_data" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "eks_addons" {
  type    = any
  default = {}
}
