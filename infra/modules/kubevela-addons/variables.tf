variable "aws_profile" {
  description = "AWS profile to use for deployment"
  type = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type = string
}

variable "cluster_version" {
  description = "Version of the Kubernetes cluster"
  type = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  type = string
}

variable "cluster_certificate_authority_data" {
  description = "Certificate authority data for the Kubernetes cluster"
  type = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the Kubernetes cluster"
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