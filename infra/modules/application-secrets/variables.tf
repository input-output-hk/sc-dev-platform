variable "marlowe_oracle_preprod_address" {
  description = "The address for the preprod Marlowe oracle"
  type = string
}

variable "marlowe_oracle_preprod_skey" {
  description = "The skey for the preprod Marlowe oracle"
  type = string
}

variable "marlowe_oracle_preprod_vkey" {
  description = "The vkey for the preprod Marlowe oracle"
  type = string
}

variable "nixbuild_net_token" {
  description = "The cluster-wide nixbuild.net build token"
  type = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}
