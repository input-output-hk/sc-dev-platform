terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.0.0-rc.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
