locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  project = local.environment_vars.locals.project
  profile = local.account_vars.locals.aws_profile
  tribe   = local.account_vars.locals.tribe
  name    = "vpc-peering-grafana"

  # AWS Regions
  requester_region = local.environment_vars.locals.aws_region
  accepter_region  = "us-east-2"
}

terraform {
  source = "github.com/cloudposse/terraform-aws-vpc-peering-multi-account?ref=0.19.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Requester VPC
dependency "vpc_us_east_1" {
  config_path = "${get_repo_root()}/infra/aws/us-east-1/prod/vpc"
}

# Accepter VPC
dependency "vpc_us_east_2" {
  config_path = "${get_repo_root()}/infra/aws/us-east-2/prod/grafana/vpc"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  # Requester inputs
  requester_aws_assume_role_arn = "" # This disables assume-role function
  requester_aws_profile         = local.profile
  requester_region              = local.requester_region
  requester_vpc_id              = dependency.vpc_us_east_1.outputs.vpc_id

  # Accepter inputs
  accepter_aws_profile = local.profile
  accepter_region      = local.accepter_region
  accepter_vpc_id      = dependency.vpc_us_east_2.outputs.vpc_id

  # Common inputs
  auto_accept                               = true
  requestor_allow_remote_vpc_dns_resolution = true
  acceptor_allow_remote_vpc_dns_resolution  = true

  tags = {
    Name = local.name
  }
}