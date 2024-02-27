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
  zone_id     = "Z10147571DRRDCJXSER5Y"
  name       = "atlantis-acm"
}


include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-acm?ref=v5.0.0"
}

inputs = {
  domain_name = "atlantis-ec2.scdev.aws.iohkdev.io"
  zone_id     = local.zone_id

  validation_method = "DNS"
  
  tags = {
    Name = "${local.name}"
    Tribe = "${local.tribe}"
    Environment = "${local.env}"
    Project = "${local.project}"
  }
}
