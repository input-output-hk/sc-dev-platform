locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  profile      = local.account_vars.locals.aws_profile
}

generate "data_sources" {
  path      = "data_sources.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    data "aws_eks_cluster" "cluster" {
      name = var.cluster_name
    }
  EOF
}

generate "k8s_provider" {
  path      = "k8s_provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "kubernetes" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id, "--profile", "${local.profile}"]
      }
    }
  EOF
}

generate "helm_provider" {
  path      = "helm_provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF

    provider "helm" {
      kubernetes {
        host                   = data.aws_eks_cluster.cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id, "--profile", "${local.profile}"]
        }
      }
    }
  EOF
}

generate "kubectl_provider" {
  path = "kubectl_provider.tf"
  if_exists = "overwrite"
  contents = <<-EOF
    terraform {
      required_providers {
        kubectl = {
          source  = "gavinbunney/kubectl"
          version = "~> 1.14"
        }
      }
    }
    provider "kubectl" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id, "--profile", "${local.profile}"]
      }
    }
  EOF
}