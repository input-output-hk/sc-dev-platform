variable "enabled" {
  description = "Switch to enable or disable"
  type        = bool
  default     = "false"
}

variable "namespace" {
  description = "Set the namesapce to deploy APISIX ingress into"
  type        = string
  default     = "ingress-apisix"
}

variable "region" {
  description = "The region being installed into"
  type        = string
}

variable "account_name" {
  description = "The account_name being installed into"
  type        = string
}

variable "aws_account_id" {
  description = "The aws_account_id being installed into"
  type        = string
}

variable "secret_prefix" {
  description = "the prefix of all secrets for this module instantiation"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "EKS cluster oidc issuer url"
  type        = string
}

variable "arn-partition" {
  description = "ARN partition"
  default     = ""
  type        = string
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
