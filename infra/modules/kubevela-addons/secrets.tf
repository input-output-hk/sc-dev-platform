resource "kubectl_manifest" "iohk-ghcr-creds" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "iohk-ghcr-creds"
      namespace = var.secrets_namespace
    }
    data = {
      ".dockerconfigjson" = var.iohk_ghcr_creds_dockerconfigjson
      input-properties  = var.iohk_ghcr_creds_input_properties
    }
  })
}

resource "kubectl_manifest" "gh-oauth" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "gh-oauth"
      namespace = var.secrets_namespace
    }
    data = {
      callbackPath     = var.gh_oauth_callbackPath
      clientID         = var.gh_oauth_clientID
      clientSecret     = var.gh_oauth_clientSecret
      input-properties = var.gh_oauth_input_properties
    }
  })
}

resource "kubectl_manifest" "jwt-signature" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "jwt-signature"
      namespace = var.secrets_namespace
    }
    data = {
      JWT_SIGNATURE    = var.jwt_signature
      input-properties = var.jwt_signature_input_properties
    }
  })
}
