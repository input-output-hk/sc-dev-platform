terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = "~> 2.0, != 2.12"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.0"
    }
  }
}
