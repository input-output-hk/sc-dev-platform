resource "kubectl_manifest" "marlowe-oracle-preprod-secrets" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "marlowe-oracle-preprod"
      namespace = "marlowe-production"
    }
    data = {
      address = base64encode(var.marlowe_oracle_preprod_address)
      skey = base64encode(var.marlowe_oracle_preprod_skey)
      vkey = base64encode(var.marlowe_oracle_preprod_vkey)
    }
  })
}

resource "kubectl_manifest" "nbn-certification" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "nbn"
      namespace = "dapps-certification-staging"
    }
    data = {
      token = base64encode(var.nixbuild_net_token)
    }
  })
}
