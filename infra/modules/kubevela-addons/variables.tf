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

variable "namespace" {
  type    = string
  default = "vela-system"
}

variable "helm_defaults" {
  description = "Customize default Helm behavior"
  type        = any
  default     = {}
}

variable "velaux_domain" {
  description = "domain where VelaUX will be hosted"
  type        = string
}

variable "dex_client_id" {
  description = "client ID for dex provider"
  type        = string
  sensitive   = true
}

variable "dex_client_secret" {
  description = "client secret for dex provider"
  type        = string
  sensitive   = true
}