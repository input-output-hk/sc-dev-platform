locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  cluster_vars     = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))

  # Extract out common variables for reuse
  env            = local.environment_vars.locals.environment
  region         = local.environment_vars.locals.aws_region
  profile        = local.account_vars.locals.aws_profile
  aws_account_id = local.account_vars.locals.aws_account_id
  users          = local.account_vars.locals.users
  tribe          = local.account_vars.locals.tribe
  project        = local.account_vars.locals.project
  name           = local.cluster_vars.locals.cluster_name
  version        = local.cluster_vars.locals.version

  list_users = concat([for user in local.users :
    "arn:aws:iam::${local.aws_account_id}:user/${user}"
  ], ["arn:aws:iam::${local.aws_account_id}:role/AtlantisDeploymentRole"])

  map_roles = [{
    rolearn  = "arn:aws:iam::${local.aws_account_id}:role/AtlantisDeploymentRole"
    username = "atlantis"
    groups   = ["system:masters"]
  }]

  map_users = [for user in local.users : {
    userarn  = "arn:aws:iam::${local.aws_account_id}:user/${user}"
    username = user
    groups   = ["system:masters"]
  }]
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${get_repo_root()}/infra/modules/eks"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# VPC as dependency
dependency "vpc" {
  config_path = "../../../vpc"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  cluster_name    = local.name
  cluster_version = local.version

  cluster_endpoint_public_access = true

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = concat(dependency.vpc.outputs.private_subnets, dependency.vpc.outputs.public_subnets)
  control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets

  eks_managed_node_group_defaults = {
    ami_release_version = ""1.19.0-2b1a7872"
  }

  eks_managed_node_groups = {
    "worker" = {
      instance_types = ["t3a.xlarge"]
      subnet_ids     = dependency.vpc.outputs.private_subnets
      labels = {
        network = "private"
      }
    }
    "worker-memory" = {
      min_size       = 3
      max_size       = 9
      instance_types = ["t3a.2xlarge"]
      subnet_ids     = dependency.vpc.outputs.private_subnets
      labels = {
        network = "private"
      }
    }
  }

  # aws-auth configmap
  aws_auth_roles = local.map_roles
  aws_auth_users = local.map_users

  kms_key_owners         = local.list_users
  kms_key_administrators = local.list_users
}
