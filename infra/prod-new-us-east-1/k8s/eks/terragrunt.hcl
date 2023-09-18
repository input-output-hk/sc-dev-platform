locals {
  # Set kubernetes provider
  k8s = read_terragrunt_config("${get_parent_terragrunt_dir()}/provider-configs/k8s.hcl")

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env            = local.environment_vars.locals.environment
  region         = local.environment_vars.locals.aws_region
  profile        = local.account_vars.locals.aws_profile
  aws_account_id = local.account_vars.locals.aws_account_id
  users          = local.account_vars.locals.users
  project        = local.account_vars.locals.project
  name           = "${local.project}-${local.env}-${local.region}"
  kubeconfigPath = "${get_parent_terragrunt_dir()}/kubeconfig-${local.name}"

  list_users = [for user in local.users :
    "arn:aws:iam::${local.aws_account_id}:user/${user}"
  ]

  map_users = [for user in local.users : {
    userarn  = "arn:aws:iam::${local.aws_account_id}:user/${user}"
    username = user
    groups   = ["system:masters"]
  }]


  tags = {
    Environment = "prod"
    Terraform   = "true"
    Project     = local.project
  }

  asg_tags = {
    "k8s.io/cluster-autoscaler/${local.name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"       = true
  }

  bootstrap_cmd = <<-EOT
        "max-pods" = ${run_cmd("--terragrunt-quiet", "/bin/sh", "-c", "AWS_REGION=${local.region} AWS_PROFILE=${local.profile} ${get_terragrunt_dir()}/max-pods-calculator.sh --instance-type t3a.large --cni-version 1.11.4")}
        EOT

  #  role_arn     = "arn:aws:iam::*******:role/terraform-master-access"
}
# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-eks//.?ref=v19.16.0"

  after_hook "kubeconfig" {
    commands = ["apply"]
    execute  = ["bash", "-c", "aws eks update-kubeconfig --profile ${local.profile} --name ${local.name} --region ${local.region} --kubeconfig ${local.kubeconfigPath} 2>/dev/null"]
  }

}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# VPC as dependency
dependency "vpc" {
  config_path = "../../vpc"
}

dependency "encryption_config" {
  config_path = "../../encryption-config"
}

# Generate k8s provider block
generate = local.k8s.generate

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  cluster_name     = local.name
  k8s-cluster-name = local.name # For provider block

  cluster_version = "1.26"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_encryption_config = {
    provider_key_arn = dependency.encryption_config.outputs.arn
    resources        = ["secrets"]
  }

  cluster_addons = {
    coredns = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
  }

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
    ingress_node_port_tcp_1 = {
      from_port        = 1025
      to_port          = 5472 # Exclude calico-typha port 5473
      protocol         = "tcp"
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_node_port_tcp_2 = {
      from_port        = 5474
      to_port          = 10249 # Exclude kubelet port 10250
      protocol         = "tcp"
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_node_port_tcp_3 = {
      from_port        = 10251
      to_port          = 10255 # Exclude kube-proxy HCHK port 10256
      protocol         = "tcp"
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_node_port_tcp_4 = {
      from_port        = 10257
      to_port          = 61677 # Exclude aws-node port 61678
      protocol         = "tcp"
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_node_port_tcp_5 = {
      from_port        = 61679
      to_port          = 65535
      protocol         = "tcp"
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_node_port_udp = {
      from_port        = 1025
      to_port          = 65535
      protocol         = "udp"
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
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

  #EKS managed node groups
  eks_managed_node_group_defaults = {
    tags                = merge(local.tags, local.asg_tags)
    desired_size        = 4
    min_size            = 1
    max_size            = 20
    capacity_type       = "ON_DEMAND"
    platform            = "bottlerocket"
    ami_release_version = "1.14.3-764e37e4"
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
          kms_key_id            = dependency.encryption_config.outputs.arn
        }
      }
      containers = {
        device_name = "/dev/xvdb"
        ebs = {
          volume_size           = 50
          volume_type           = "gp3"
          delete_on_termination = true
          encrypted             = true
          kms_key_id            = dependency.encryption_config.outputs.arn
        }
      }
    }
  }

  eks_managed_node_groups = {
    "d-a" = {
      ami_type                   = "BOTTLEROCKET_x86_64"
      instance_types             = ["t3a.xlarge"]
      subnet_ids                 = [dependency.vpc.outputs.private_subnets[0]]
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = local.bootstrap_cmd
      labels = {
        network = "private"
      }
    }

    "d-b" = {
      ami_type                   = "BOTTLEROCKET_x86_64"
      instance_types             = ["t3a.xlarge"]
      subnet_ids                 = [dependency.vpc.outputs.private_subnets[1]]
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = local.bootstrap_cmd
      labels = {
        network = "private"
      }
    }
    "d-c" = {
      ami_type                   = "BOTTLEROCKET_x86_64"
      platform                   = "bottlerocket"
      instance_types             = ["t3a.2xlarge"]
      subnet_ids                 = [dependency.vpc.outputs.private_subnets[2]]
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = local.bootstrap_cmd
      labels = {
        network = "private"
      }
    }

    # "cardano-128" = {
    #   ami_type                   = "BOTTLEROCKET_x86_64"
    #   platform                   = "bottlerocket"
    #   desired_size               = 1
    #   min_size                   = 0
    #   max_size                   = 1
    #   instance_types             = ["r5a.4xlarge"]
    #   subnet_ids                 = [dependency.vpc.outputs.private_subnets[0]]
    #   enable_bootstrap_user_data = true
    #   bootstrap_extra_args       = local.bootstrap_cmd
    #   labels = {
    #     mainnet = "true"
    #   }
    #   taints = [
    #     {
    #       key    = "mainnet"
    #       value  = "true"
    #       effect = "NO_SCHEDULE"
    #     }
    #   ]
    # }

  }
  # aws-auth configmap
  manage_aws_auth_configmap = true
  create_aws_auth_configmap = true

  kms_key_owners         = local.list_users
  kms_key_administrators = local.list_users

  aws_auth_users = local.map_users

  aws_auth_roles = []

  tags = local.tags
}
