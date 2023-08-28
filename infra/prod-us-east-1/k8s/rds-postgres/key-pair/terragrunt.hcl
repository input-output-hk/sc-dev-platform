locals {

  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project        = local.account_vars.locals.project
  app            = "marlowe-runtime"

  bastion_name          = "${local.project}-${local.app}-bastion"
  bastion_key_pair_name = "${local.project}-${local.app}-db-bastion-kp"

  tags = {
    organization = "iog"
    tribe        = "smart-contracts"
    environment  = "prod"
    function     = "bastion-key-pair"
    App          = "marlowe-runtime"
    Environment  = "prod"
    Terraform    = "true"
    Project      = local.project
    Resource     = local.bastion_name
  }

}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-key-pair//.?ref=v2.0.2"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  key_name           = local.bastion_key_pair_name
  create_private_key = true

  tags = local.tags
}
