terraform {
  required_providers {
    helm       = "~> 2.0"
    kubernetes = "~> 2.0, != 2.12"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.0"
    }
    kustomization = {
      source  = "kbst/kustomize"
      version = "0.2.0-beta.3"
    }
  }
}