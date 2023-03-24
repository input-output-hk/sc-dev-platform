terraform {
  required_providers {
    helm       = "~> 2.0"
    kubernetes = "~> 2.0, != 2.12"
    curl = {
      source  = "anschoewe/curl"
      version = "~> 1.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.0"
    }
  }
}
