locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  cidr_prefix = local.environment_vars.locals.cidr_prefix
  project     = local.environment_vars.locals.project
  tribe       = local.account_vars.locals.tribe
  name        = "${local.project}-${local.env}-${local.region}"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc.git//.?ref=v5.1.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = local.name
  cidr = "${local.cidr_prefix}.0.0/16"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets  = ["${local.cidr_prefix}.48.0/20", "${local.cidr_prefix}.64.0/20", "${local.cidr_prefix}.80.0/20"]    # /20 will allow 4096 ips per subnet
  public_subnets   = ["${local.cidr_prefix}.0.0/20", "${local.cidr_prefix}.16.0/20", "${local.cidr_prefix}.32.0/20"]     # /20 will allow 4096 ips per subnet
  intra_subnets    = ["${local.cidr_prefix}.96.0/22", "${local.cidr_prefix}.100.0/22", "${local.cidr_prefix}.104.0/22"]  # /22 will allow 1024 ips per subnet
  database_subnets = ["${local.cidr_prefix}.108.0/22", "${local.cidr_prefix}.112.0/22", "${local.cidr_prefix}.116.0/22"] # /22 will allow 1024 ips per subnet

  enable_nat_gateway          = true
  single_nat_gateway          = true
  one_nat_gateway_per_az      = false
  database_subnet_group_name  = "${local.env}-subnet-group"
  create_database_route_table = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }



  map_public_ip_on_launch       = true
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

}
