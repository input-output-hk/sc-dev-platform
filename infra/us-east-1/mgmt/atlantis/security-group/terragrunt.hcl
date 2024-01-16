locals {

  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project        = local.account_vars.locals.project
  app            = "atlantis"

  bastion_name          = "${local.project}-${local.app}-bastion"
  bastion_key_pair_name = "${local.project}-${local.app}-db-bastion-kp"

}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group//.?ref=v5.1.0/modules/ssh"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  computed_ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_cidr_blocks          = ["0.0.0.0/0"]
}
