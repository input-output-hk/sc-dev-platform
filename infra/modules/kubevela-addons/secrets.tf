resource "kubectl_manifest" "iohk-ghcr-creds" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "iohk-ghcr-creds"
      namespace = var.secrets_namespace
    }
    data = {
      ".dockerconfigjson" = var.cluster_secrets.iohk_ghcr_creds_dockerconfigjson
      input-properties  = var.cluster_secrets.iohk_ghcr_creds_input_properties
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
      callbackPath     = var.cluster_secrets.gh_oauth_callbackPath
      clientID         = var.cluster_secrets.gh_oauth_clientID
      clientSecret     = var.cluster_secrets.gh_oauth_clientSecret
      input-properties = var.cluster_secrets.gh_oauth_input_properties
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
      JWT_SIGNATURE    = var.cluster_secrets.jwt_signature
      input-properties = var.cluster_secrets.jwt_signature_input_properties
    }
  })
}
