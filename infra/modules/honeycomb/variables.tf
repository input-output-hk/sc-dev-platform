variable "cluster_name" {
  type = string
}

variable "honeycomb_api_key" {
  type      = string
  sensitive = true
}
