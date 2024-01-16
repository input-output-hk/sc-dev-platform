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
  name        = "scde"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v5.6.0"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "security_group" {
  config_path = "../security-group"
}

inputs = {
   name = local.name
   instance_type = "t2.micro"
   
   
   create_iam_instance_profile = true
   iam_role_description        = "IAM role for EC2 instance"
    iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    }

   subnet_id              = dependency.vpc.outputs.public_subnets[0]

  vpc_security_group_ids = [dependency.security_group.outputs.security_group_id]
}

