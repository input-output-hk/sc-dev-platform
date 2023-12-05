locals {
  dex_connector_data = "{\"clientID\":${var.dex_client_id},\"clientSecret\":${var.dex_client_secret},\"hostedDomains\":[\"iohk.io\"],\"redirectURI\":\"https://${var.velaux_domain}/callback\"}"
}

resource "kubernetes_secret" "dex-config" {
  count = var.enable_dex ? 1 : 0
  metadata {
    name      = "dex-config"
    namespace = var.namespace
  }

  data = {
    "config.yaml" = yamlencode({
      connectors = [
        {
          config = {
            clientID      = var.dex_client_id,
            clientSecret  = var.dex_client_secret,
            hostedDomains = ["iohk.io"],
            redirectURI   = "https://${var.velaux_domain}/dex/callback",
          },
          id   = "google",
          name = "google",
          type = "google",
        },
      ],
      enablePasswordDB = true,
      frontend = {
        Issuer  = "KubeVela",
        LogoURL = "",
        Theme   = "",
      },
      issuer = "https://${var.velaux_domain}/dex",
      staticClients = [
        {

          id           = "velaux",
          name         = "VelaUX",
          redirectURIs = ["https://${var.velaux_domain}/callback"],
          secret : "velaux-secret",
        }

      ]
      storage = {
        config = {
          inCluster : true
        }
        type = "kubernetes"
      }
      telemetry = {
        http = "",
      }
      web = {
        allowedOrigins = [],
        http           = "0.0.0.0:5556",
        https          = "",
        tlsCert        = "",
        tlsKey         = ""
      }
    })
  }
}

resource "kubernetes_secret" "dex-connector" {
  metadata {
    name      = "google"
    namespace = var.namespace

    annotations = {
      "config.oam.dev/alias"              = ""
      "config.oam.dev/description"        = ""
      "config.oam.dev/sensitive"          = "false"
      "config.oam.dev/template-namespace" = "vela-system"
    }

    labels = {
      "config.oam.dev/catalog"  = "velacore-config"
      "config.oam.dev/scope"    = "system"
      "config.oam.dev/sub-type" = "google"
      "config.oam.dev/type"     = "dex-connector"
    }
  }

  data = {
    "google" : local.dex_connector_data
    "input-properties" : local.dex_connector_data
  }
}
