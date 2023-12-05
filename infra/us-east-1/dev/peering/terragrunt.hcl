locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  project = local.environment_vars.locals.project
  tribe   = local.account_vars.locals.tribe
  name    = "VPC Peering"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "github.com/cloudposse/terraform-aws-vpc-peering//.?ref=1.0.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Requester VPC
dependency "vpc_dev_us_east_1" {
  config_path = "${get_repo_root()}/infra/us-east-1/dev/vpc"
}

# Accepter VPC
dependency "vpc_mng_us_east_1" {
  config_path = "${get_repo_root()}/infra/us-east-1/prod/management-vpc"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  # Input variables specific to the VPC peering module
  requestor_vpc_id = dependency.vpc_dev_us_east_1.outputs.vpc_id # Dev VPC
  acceptor_vpc_id  = dependency.vpc_mng_us_east_1.outputs.vpc_id # Management VPC
}
