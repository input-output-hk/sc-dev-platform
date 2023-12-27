resource "kubectl_manifest" "iohk-ghcr-creds" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "iohk-ghcr-creds"
      namespace = var.namespace
    }
    data = {
      ".dockerconfigjson" = var.iohk-ghcr-creds-dockerconfigjson
      input-properties  = var.iohk-ghcr-creds-input-properties
    }
  })
}

resource "kubectl_manifest" "gh-oauth" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "gh-oauth"
      namespace = var.namespace
    }
    data = {
      callbackPath     = var.gh-oauth-callbackPath
      clientID         = var.gh-oauth-clientID
      clientSecret     = var.gh-oauth-clientSecret
      input-properties = var.gh-oauth-input-properties
    }
  })
}

resource "kubectl_manifest" "jwt-signature" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "jwt-signature"
      namespace = var.namespace
    }
    data = {
      JWT_SIGNATURE    = var.jwt-signature
      input-properties = var.jwt-signature-input-properties
    }
  })
}
