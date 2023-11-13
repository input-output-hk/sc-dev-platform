locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  project     = local.environment_vars.locals.project
  tribe       = local.account_vars.locals.tribe
  name        = "Management-vpc"
  # New VPC configuration
  new_vpc_cidr = "10.100"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//.?ref=v5.1.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = local.name
  cidr = "${local.new_vpc_cidr}.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  public_subnets  = ["${local.new_vpc_cidr}.0.0/20", "${local.new_vpc_cidr}.16.0/20"]    # /20 will allow 4096 ips per subnet


  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "Name"  = "${local.name}.PublicSubnet"
  }


  map_public_ip_on_launch       = true
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

}
