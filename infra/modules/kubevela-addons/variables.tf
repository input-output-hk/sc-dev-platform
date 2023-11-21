variable "enable_addons" {
  description = "Feature flag to enable Addons"
  type        = bool
  default     = true
}

variable "enable_cardano_nodes" {
  description = "Feature flag to enable Cardano Nodes"
  type        = bool
  default     = true
}

variable "enable_dex" {
  description = "Feature flag to enable Dex"
  type        = bool
  default     = true
}

variable "aws_profile" {
  description = "AWS profile to use for deployment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account id"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the Kubernetes cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Certificate authority data for the Kubernetes cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the Kubernetes cluster"
  type        = string
}

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

variable "velaux_domain" {
  description = "domain where VelaUX will be hosted"
  type        = string
  default     = ""
}

variable "dex_client_id" {
  description = "client ID for dex provider"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dex_client_secret" {
  description = "client secret for dex provider"
  type        = string
  sensitive   = true
  default     = ""
}

variable "rds_security_groups" {
  description = "List of security groups used for RDS connectivity"
  type        = list(string)
}

variable "addons_dir" {
  description = "Directory containing the addons manifests"
  type        = string
  default     = "./addons"
}
