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
  name        = "management-vpc"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.1.1"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name = local.name
  cidr = "${local.cidr_prefix}.0.0/16"

  azs            = ["${local.region}a", "${local.region}b"]
  public_subnets = ["${local.cidr_prefix}.0.0/20", "${local.cidr_prefix}.16.0/20"]
  private_subnets = ["${local.cidr_prefix}.32.0/20", "${local.cidr_prefix}.48.0/20", "${local.cidr_prefix}.64.0/20"]

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "Name" = "${local.name}-public-subnet"
  }

  map_public_ip_on_launch       = true
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
}