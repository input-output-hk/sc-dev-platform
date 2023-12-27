variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy variable to"
  type        = string
}

variable "jwt-signature" {
  description = "K8s secret for Marlowe JWT signature"
  type        = string
  sensitive   = true
}

variable "jwt-signature-input-properties" {
  description = "Linked with JWT signature secret"
  type        = string
  sensitive   = true
}

variable "gh-oauth-callbackPath" {
  description = "Linked with gh-oauth secret"
  type        = string
  sensitive   = true
}

variable "gh-oauth-clientID" {
  description = "Linked with gh-oauth secret"
  type        = string
  sensitive   = true
}

variable "gh-oauth-clientSecret" {
  description = "Linked with gh-oauth secret"
  type        = string
  sensitive   = true
}

variable "gh-oauth-input-properties" {
  description = "Linked with gh-oauth secret"
  type        = string
  sensitive   = true
}

variable "iohk-ghcr-creds-dockerconfigjson" {
  description = "Linked with iohk-ghcr-creds secret"
  type        = string
  sensitive   = true
}
 
variable "iohk-ghcr-creds-input-properties" {
  description = "Linked with iohk-ghcr-creds secret"
  type        = string
  sensitive   = true
}

