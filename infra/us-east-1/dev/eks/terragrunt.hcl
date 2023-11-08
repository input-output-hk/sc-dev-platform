locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  #  cluster_vars     = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))

  # Extract out common variables for reuse
  env            = local.environment_vars.locals.environment
  region         = local.environment_vars.locals.aws_region
  profile        = local.account_vars.locals.aws_profile
  aws_account_id = local.account_vars.locals.aws_account_id
  users          = local.account_vars.locals.users
  tribe          = local.account_vars.locals.tribe
  project        = local.account_vars.locals.project
  name           = "${local.environment_vars.locals.project}-${local.environment_vars.locals.environment}-${local.environment_vars.locals.aws_region}"
  version        = "1.26"

  list_users = [for user in local.users :
    "arn:aws:iam::${local.aws_account_id}:user/${user}"
  ]

  map_users = [for user in local.users : {
    userarn  = "arn:aws:iam::${local.aws_account_id}:user/${user}"
    username = user
    groups   = ["system:masters"]
  }]
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "github.com/input-output-hk/sc-dev-platform.git//infra/modules/eks"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# VPC as dependency
dependency "vpc" {
  config_path = "../vpc"
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
    # aws ssm get-parameters-by-path --path /aws/service/bottlerocket/aws-k8s-1.26/x86_64/latest/ --region us-east-1 \
    # --recursive | jq -r '.Parameters[1].Value'
    ami_release_version = "1.16.0-d2d9cf87"
  }

  eks_managed_node_groups = {
    "worker" = {
      instance_types = ["t3.medium", "t3a.medium"]
      min_size       = 3
      max_size       = 6
      desired_size   = 3
      subnet_ids     = dependency.vpc.outputs.private_subnets
      labels = {
        network = "private"
      }
    }
  }

  # aws-auth configmap
  aws_auth_users = local.map_users

  kms_key_owners         = local.list_users
  kms_key_administrators = local.list_users
}
