locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  project = local.environment_vars.locals.project
  tribe   = local.account_vars.locals.tribe
  name    = "vpc-peering-prod-dapps"
}

dependency "vpc_prod" {
  config_path = "${get_repo_root()}/infra/us-east-1/prod/vpc"
}

dependency "vpc_prod_old" {
  config_path = "${get_repo_root()}/infra/prod-us-east-1/vpc"
}

terraform {
  source = "github.com/cloudposse/terraform-aws-vpc-peering//.?ref=1.0.0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  requestor_vpc_id = dependency.vpc_prod.outputs.vpc_id
  acceptor_vpc_id  = dependency.vpc_prod_old.outputs.vpc_id

  tags = {
    Name = local.name
  }
}