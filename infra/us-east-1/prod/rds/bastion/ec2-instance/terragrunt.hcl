locals {

  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project        = local.account_vars.locals.project
  app            = "marlowe-runtime"

  bastion_name       = "${local.project}-${local.app}-database-bastion"

}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v5.3.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "key_pair" {
 config_path = "../key-pair"
}

dependency "vpc" {
  config_path = "../../../vpc"
}

dependency "security_group" {
  config_path = "../security-group"
}

dependency "eks" {
  config_path = "../../../eks/green/eks"
}

inputs = {
  name          = local.bastion_name
  instance_type = "t2.micro"
  key_name      = dependency.key_pair.outputs.key_pair_name

  subnet_id              = dependency.vpc.outputs.public_subnets[0]
  vpc_security_group_ids = [dependency.security_group.outputs.security_group_id, dependency.eks.outputs.node_security_group_id]
}
