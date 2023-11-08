resource "kubernetes_secret" "dex-config" {
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
        allowedOrigins = "null",
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
      "config.oam.dev/alias" = ""
      "config.oam.dev/description" = ""
      "config.oam.dev/sensitive" = "false"
      "config.oam.dev/template-namespace" = "vela-system"
    }

    labels = {
     "config.oam.dev/catalog" = "velacore-config"
     "config.oam.dev/scope" = "system"
     "config.oam.dev/sub-type" = "google"
     "config.oam.dev/type" = "dex-connector"
    }
  }

 data = {
   "google": "{\"clientID\":${var.dex_client_id},\"clientSecret\":${var.dex_client_secret},\"hostedDomains\":[\"iohk.io\"],\"redirectURI\":\"https://${var.velaux_domain}/callback\"}"
   "input-properties": "{\"clientID\":${var.dex_client_id},\"clientSecret\":${var.dex_client_secret},\"hostedDomains\":[\"iohk.io\"],\"redirectURI\":\"https://${var.velaux_domain}/callback\"}"
 }
}