terraform {
  required_providers {
    helm       = "~> 2.0"
    kubernetes = "~> 2.0, != 2.12"
  }
}
