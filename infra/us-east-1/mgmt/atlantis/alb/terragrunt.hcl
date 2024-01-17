locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  project     = local.environment_vars.locals.project
  cidr_prefix = local.environment_vars.locals.cidr_prefix
  tribe       = local.account_vars.locals.tribe
  name        = "atlantis-${local.env}-${local.tribe}-alb"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb?ref=v9.4.1"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "security_group" {
  config_path = "../security-group"
}

dependency "key_pair" {
 config_path = "../key-pair"
}

inputs = {
    name = local.name
    vpc_id = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.public_subnets
    
    enable_delete_protection = false

    security_group_ingress_rules = {
        all_http = {
          from_port   = 80
          to_port     = 82
          ip_protocol = "tcp"
          description = "HTTP web traffic"
          cidr_ipv4   = "0.0.0.0/0"
        }
        all_https = {
          from_port   = 443
          to_port     = 445
          ip_protocol = "tcp"
          description = "HTTPS web traffic"
          cidr_ipv4   = "0.0.0.0/0"
        }
    }
    security_group_egress_rules = {
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = dependency.vpc.outputs.vpc_cidr_block
        }
  }

}

