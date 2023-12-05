locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  project     = local.environment_vars.locals.project
  tribe       = local.account_vars.locals.tribe
  name        = "VPC Peering"
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

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  # Input variables specific to the VPC peering module
  requestor_vpc_id  = "vpc-05d9f25d63d8ffb04"  # Management VPC ID
  acceptor_vpc_id   = "vpc-099d582f5470a11f3"  # EKS VPC ID

}

