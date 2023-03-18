include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/particuleio/terraform-kubernetes-addons.git//modules/aws?ref=v10.3.0"
}

locals {
  # Set kubernetes based providers
  k8s = read_terragrunt_config(find_in_parent_folders("k8s-addons.hcl"))
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  profile = local.account_vars.locals.aws_profile
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_id              = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
  }
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    private_subnets_cidr_blocks = [
      "10.0.0.0/16",
      "192.168.0.0/24"
    ]
  }
}

generate = local.k8s.generate

inputs = {

  cluster-name = dependency.eks.outputs.cluster_id

  eks = {
    "cluster_oidc_issuer_url" = dependency.eks.outputs.cluster_oidc_issuer_url
  }

  aws-load-balancer-controller = {
    enabled = true
  }

  cluster-autoscaler = {
    enabled      = true
    version      = "v1.25.0"
    cluster-name = dependency.eks.outputs.cluster_id
    extra_values = <<-EXTRA_VALUES
    extraArgs:
      scale-down-utilization-threshold: 0.7
    EXTRA_VALUES
  }

  metrics-server = {
    enabled       = true
    allowed_cidrs = ["10.10.0.0/16"]
  }

  external-dns = {
    external-dns = {
      enabled      = true
      extra_values = <<-EXTRA_VALUES
      domainFilters: [dapps.iohkdev.io]
      EXTRA_VALUES
    }
  }

  csi-external-snapshotter = {
    enabled = true
  }

  aws-ebs-csi-driver = {
    enabled          = true
    is_default_class = false
    wait             = false
    use_encryption   = true
    use_kms          = true
  }

  cert-manager = {
    enabled             = true
    acme_http01_enabled = true
    acme_dns01_enabled  = true
    acme_email          = "smart.contracts@iohk.io"
    extra_values        = <<-EXTRA_VALUES
      ingressShim:
        defaultIssuerName: letsencrypt
        defaultIssuerKind: ClusterIssuer
        defaultIssuerGroup: cert-manager.io
      EXTRA_VALUES
    csi_driver          = true
  }

}

generate "cert_issuers" {
  path = "cert_issuers.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    resource "kubernetes_manifest" "issuer_selfsigned" {
      depends_on = [
        helm_release.cert-manager
      ]
      manifest = {
        apiVersion = "cert-manager.io/v1"
        kind = "ClusterIssuer"
        metadata = {
          name = "selfsigned"
        }
        spec = {
          selfSigned = {}
        }
      }
      wait {
        condition {
          type   = "Ready"
          status = "True"
        }
      }
    }
    resource "kubernetes_manifest" "certificate_root_ca" {
      depends_on = [
        helm_release.cert-manager
      ]
      manifest = {
        apiVersion = "cert-manager.io/v1"
        kind = "Certificate"
        metadata = {
          name = "root-ca"
          namespace = "cert-manager"
        }
        spec = {
          isCA = "true"
          commonName = "root-ca"
          secretName = "root-secret"
          privateKey = {
            algorithm = "ECDSA"
            size = "256"
          }
          issuerRef = {
            name = "selfsigned"
            kind = "ClusterIssuer"
            group = "cert-manager.io"
          }
        }
      }
      wait {
        condition {
          type   = "Ready"
          status = "True"
        }
      }
    }
    resource "kubernetes_manifest" "issuer_root_ca" {
      depends_on = [
        helm_release.cert-manager
      ]
      manifest = {
        apiVersion = "cert-manager.io/v1"
        kind = "ClusterIssuer"
        metadata = {
          name = "root-ca"
        }
        spec = {
          ca = {
            secretName = "root-secret"
          }
        }
      }
      wait {
        condition {
          type   = "Ready"
          status = "True"
        }
      }
    }
    resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
      manifest = {
        "apiVersion" = "cert-manager.io/v1"
        "kind" = "ClusterIssuer"
        "metadata" = {
          "name" = "letsencrypt"
        }
        "spec" = {
          "acme" = {
            "email" = "smart.contracts@iohk.io"
            "privateKeySecretRef" = {
              "name" = "letsencrypt"
            }
            "server" = "https://acme-v02.api.letsencrypt.org/directory"
            "solvers" = [
              {
                "dns01" = {
                  "route53" = {
                    "region" = "us-east-1"
                    "role" = "${module.iam_assumable_role_cert-manager.iam_role_arn}"
                  }
                }
                "selector" = {
                  "dnsZones" = [
                    "dapps.iohkdev.io",
                  ]
                }
              },
            ]
          }
        }
      }
    }

    resource "kubernetes_manifest" "certificate_dapps_iohkdev_io" {
      manifest = {
        "apiVersion" = "cert-manager.io/v1"
        "kind" = "Certificate"
        "metadata" = {
          "name" = "dapps-iohkdev-io"
          "namespace" = "default"
        }
        "spec" = {
          "commonName" = "*.dapps.iohkdev.io"
          "dnsNames" = [
            "dapps.iohkdev.io",
            "*.dapps.iohkdev.io",
          ]
          "issuerRef" = {
            "kind" = "ClusterIssuer"
            "name" = "letsencrypt"
          }
          "secretName" = "dapps-iohkdev-io-tls"
        }
      }
    }
  EOF
}
