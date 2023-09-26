locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  profile      = local.account_vars.locals.aws_profile
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

    # needs to be unique across k8s related modules
    variable "k8s-cluster-name" {
      type = string
    }

    data "aws_eks_cluster" "cluster" {
      name = var.k8s-cluster-name
    }
  EOF
}
