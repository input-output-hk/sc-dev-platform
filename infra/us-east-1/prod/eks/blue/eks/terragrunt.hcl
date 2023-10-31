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

  list_users = [for user in local.users :
    "arn:aws:iam::${local.aws_account_id}:user/${user}"
  ]

  map_users = [for user in local.users : {
    userarn  = "arn:aws:iam::${local.aws_account_id}:user/${user}"
    username = user
    groups   = ["system:masters"]
  }]

  asg_tags = {
    "k8s.io/cluster-autoscaler/${local.name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"       = true
  }

  tags = {}
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
  config_path = "../../../vpc"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  cluster_name    = local.name
  cluster_version = local.version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = concat(dependency.vpc.outputs.private_subnets, dependency.vpc.outputs.public_subnets)
  control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets

  node_security_group_additional_rules = {
    ingress_self_all = {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      type      = "ingress"
      self      = true
    }
    ingress_cluster_all = {
      from_port                     = 0
      to_port                       = 0
      protocol                      = "-1"
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # EKS managed node groups
  eks_managed_node_group_defaults = {
    tags                = local.asg_tags
    desired_size        = 3
    min_size            = 3
    max_size            = 12
    capacity_type       = "ON_DEMAND"
    platform            = "bottlerocket"
    ami_release_version = "1.15.1-264e294c"
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    ebs_optimized = true
    update_config = {
      max_unavailable_percentage = 33
    }
    block_device_mappings = {
      root = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 2
          volume_type           = "gp3"
          delete_on_termination = true
          encrypted             = true
        }
      }
      containers = {
        device_name = "/dev/xvdb"
        ebs = {
          volume_size           = 50
          volume_type           = "gp3"
          delete_on_termination = true
          encrypted             = true
        }
      }
    }
  }

  eks_managed_node_groups = {
    "worker" = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3a.xlarge"]
      subnet_ids     = dependency.vpc.outputs.private_subnets
      labels = {
        network = "private"
      }
    }
    "worker-memory" = {
      ami_type       = "BOTTLEROCKET_x86_64"
      min_size       = 3
      max_size       = 6
      instance_types = ["t3a.2xlarge"]
      subnet_ids     = dependency.vpc.outputs.private_subnets
      labels = {
        network = "private"
      }
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_users            = local.map_users
  aws_auth_roles            = []

  kms_key_owners         = local.list_users
  kms_key_administrators = local.list_users

  tags = local.tags

}
