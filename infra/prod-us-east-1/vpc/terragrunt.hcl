locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  project = local.account_vars.locals.project
  name    = "${local.project}-${local.env}-${local.region}"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//.?ref=tags/v3.14.4"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = local.name
  cidr = "10.10.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.10.48.0/20", "10.10.64.0/20", "10.10.80.0/20"]   # /20 will allow 4096 ips per subnet
  public_subnets  = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]    # /20 will allow 4096 ips per subnet
  intra_subnets   = ["10.10.96.0/22", "10.10.100.0/22", "10.10.104.0/22"] # /22 will allow 1024 ips per subnet

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

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

  tags = {
    Terraform   = "true"
    Environment = local.env
    Project     = local.project
  }
}
