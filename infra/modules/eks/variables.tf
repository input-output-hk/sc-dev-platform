variable "aws_profile" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_endpoint_private_access" {
  type = bool
}

variable "cluster_endpoint_public_access" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "control_plane_subnet_ids" {
  type = list(string)
}

variable "node_security_group_additional_rules" {
  type = any
}

variable "eks_managed_node_group_defaults" {
  type = any
}

variable "eks_managed_node_groups" {
  type = any
}

variable "manage_aws_auth_configmap" {
  type = bool
}

variable "aws_auth_users" {
  type = any
}

variable "aws_auth_roles" {
  type = any
}

variable "kms_key_owners" {
  type = any
}

variable "kms_key_administrators" {
  type = any
}

variable "tags" {
  type = any
}
