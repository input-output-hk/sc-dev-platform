locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  profile      = local.account_vars.locals.aws_profile
}

# Generate k8s provider block
generate "k8s_provider" {
  path      = "k8s_provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF

 provider "kubernetes" {
      host                   = aws_eks_cluster.this[0].endpoint
      cluster_ca_certificate = base64decode(aws_eks_cluster.this[0].certificate_authority.0.data)
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this[0].id, "--profile", "${local.profile}"]
      }
    }
  EOF
}
