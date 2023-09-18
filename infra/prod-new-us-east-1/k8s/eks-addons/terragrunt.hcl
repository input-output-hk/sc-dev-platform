include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/particuleio/terraform-kubernetes-addons.git//modules/aws?ref=v14.9.0"
}

locals {
  # Set kubernetes based providers
  k8s = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/k8s.hcl")
  helm = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/helm.hcl")
  kubectl = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/kubectl.hcl")

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  profile = local.account_vars.locals.aws_profile
}

generate = merge(local.k8s.generate, local.helm.generate, local.kubectl.generate)

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

inputs = {

  cluster-name = dependency.eks.outputs.cluster_name
  k8s-cluster-name = dependency.eks.outputs.cluster_name

  eks = {
    "cluster_oidc_issuer_url" = dependency.eks.outputs.cluster_oidc_issuer_url
    "oidc_provider_arn"  = dependency.eks.outputs.oidc_provider_arn
  }

  aws-load-balancer-controller = {
    enabled = true
  }

  cluster-autoscaler = {
    enabled      = true
    version      = "v1.25.0"
    cluster-name = dependency.eks.outputs.cluster_name
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
        domainFilters:
         - scdev.aws.iohkdev.io
         - play.marlowe.iohk.io
      EXTRA_VALUES
    }
  }

  traefik = {
    enabled = true
    extra_values        = <<-EXTRA_VALUES
      image:
        tag: "3.0"
      experimental:
        kubernetesGateway:
          enabled: true
      service:
        annotations:
          "external-dns.alpha.kubernetes.io/hostname": "*.scdev.aws.iohkdev.io,play.marlowe.iohk.io"
      ports:
        web:
          redirectTo: websecure

    EXTRA_VALUES

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
    chart_version       = "v1.9.1"
    acme_dns01_enabled  = false
    # create cluster issuer below so that it is exposed with https
    acme_http01_enabled = false
    extra_values        = <<-EXTRA_VALUES
      ingressShim:
        defaultIssuerName: letsencrypt
        defaultIssuerKind: ClusterIssuer
        defaultIssuerGroup: cert-manager.io
      extraArgs:
        - --feature-gates=ExperimentalGatewayAPISupport=true
    EXTRA_VALUES
    csi_driver          = true
  }
  cert-manager-csi-driver = {
    chart_version       = "v0.4.2"
  }

}

generate "letsencrypt_issuer" {
  path = "letsencrypt_issuer.tf"
  if_exists = "overwrite"
  contents = <<EOF
    resource "kubectl_manifest" "letsencrypt_issuer" {
      yaml_body = file("${get_terragrunt_dir()}/letsencrypt_issuer.yaml")
    }
  EOF
}

generate "gateway_crds" {
  path = "gateway_crds.tf"
  if_exists = "overwrite"
  contents = <<EOF
    resource "kubectl_manifest" "gateway_crds" {
      yaml_body = file("${get_terragrunt_dir()}/gateway_crds.yaml")
    }
  EOF
}
