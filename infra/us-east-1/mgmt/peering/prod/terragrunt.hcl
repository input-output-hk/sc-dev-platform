locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  project = local.environment_vars.locals.project
  tribe   = local.account_vars.locals.tribe
  name    = "vpc-peering-mgmt-prod"
}

dependency "vpc_mgmt" {
  config_path = "${get_repo_root()}/infra/us-east-1/mgmt/vpc"
}

dependency "vpc_prod" {
  config_path = "${get_repo_root()}/infra/us-east-1/prod/vpc"
}

terraform {
  source = "github.com/cloudposse/terraform-aws-vpc-peering//.?ref=1.0.0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  requestor_vpc_id = dependency.vpc_mgmt.outputs.vpc_id
  acceptor_vpc_id  = dependency.vpc_prod.outputs.vpc_id

  tags = {
    Name = local.name
  }
}