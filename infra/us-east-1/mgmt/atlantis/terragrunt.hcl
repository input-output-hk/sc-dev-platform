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
}

terraform {
  source = "../../../modules/atlantis"
}

dependency "vpc_mgmt" {
  config_path = "${get_repo_root()}/infra/us-east-1/mgmt/vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
    name = "atlantis"

    task_exec_secret_arns = [
        "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-github-token-Ns6xng",
        "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-github-webhook-secret-5LsH5r"
    ]

    service_subnets = dependency.vpc_mgmt.outputs.public_subnets
    vpc_id          = dependency.vpc_mgmt.outputs.vpc_id
    alb_subnets     = dependency.vpc_mgmt.outputs.public_subnets
    route53_zone_id = "Z10147571DRRDCJXSER5Y"
    domain_name     = "scdev.aws.iohkdev.io"
}

