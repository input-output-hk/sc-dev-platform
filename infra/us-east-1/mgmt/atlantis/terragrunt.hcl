locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-atlantis"
}

dependency "vpc" {
  config_path = "${get_repo_root()}/infra/us-east-1/mgmt/vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name = "atlantis"

  atlantis = {
    environment = [
      {
        name  = "ATLANTIS_REPO_ALLOWLIST"
        value = "github.com/input-output-hk/*"
      },
      {
        name : "ATLANTIS_REPO_CONFIG_JSON",
        value : jsonencode(yamldecode(file("server-atlantis.yaml")))
      },
      {
        name  = "ATLANTIS_WRITE_GIT_CREDS"
        value = true
      },
      {
        name  = "ATLANTIS_ENABLE_DIFF_MARKDOWN_FORMAT"
        value = "true"
      }
    ]
  //   secrets = [
  //     {
  //       name      = "ATLANTIS_GH_APP_ID"
  //       valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:gh-app-id-d8b6zU"
  //     },
  //     {
  //       name      = "ATLANTIS_GH_APP_KEY"
  //       valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-gh-app-key-iSotd9"
  //     },
  //     {
  //       name      = "ATLANTIS_GH_WEBHOOK_SECRET"
  //       valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-gh-webhook-secret-cwFbJy"
  //     }
  //   ]
  }

  # ECS Service
  service = {
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-gh-app-key-iSotd9",
      "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-gh-webhook-secret-cwFbJy",
      "arn:aws:secretsmanager:us-east-1:677160962006:secret:gh-app-id-d8b6zU"
    ]
    # Provide Atlantis permission necessary to create/destroy resources
    tasks_iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
    assign_public_ip = true
  }

  vpc_id          = dependency.vpc.outputs.vpc_id


  alb = {
    # For example only
    enable_deletion_protection = false
  }

  enable_efs = true
  efs = {
    mount_targets = {
        "eu-west-1a" = {
          subnet_id = dependency.vpc.outputs.public_subnets[0]
        }
        "eu-west-1b" = {
          subnet_id = dependency.vpc.outputs.public_subnets[1]
        }
    }
  }
  # ALB
  alb_subnets             = dependency.vpc.outputs.public_subnets
  service_subnets         = dependency.vpc.outputs.public_subnets
  certificate_domain_name = "atlantis.scdev.aws.iohkdev.io"
  route53_zone_id         = "Z10147571DRRDCJXSER5Y"
}
