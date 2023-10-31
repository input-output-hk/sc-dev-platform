provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  node_security_group_additional_rules = merge(local.node_security_group_additional_rules, var.node_security_group_additional_rules)

  cluster_addons = local.cluster_addons

  eks_managed_node_group_defaults = merge(local.eks_managed_node_group_defaults, var.eks_managed_node_group_defaults)
  eks_managed_node_groups         = var.eks_managed_node_groups

  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_users            = var.aws_auth_users
  aws_auth_roles            = var.aws_auth_roles

  kms_key_owners         = var.kms_key_owners
  kms_key_administrators = var.kms_key_administrators

  tags = var.tags
}
