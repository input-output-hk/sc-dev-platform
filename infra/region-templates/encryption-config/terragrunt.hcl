locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  project = local.account_vars.locals.project
  name    = "${local.project}-${local.env}-${local.region}"

  tags = {
    Environment = "prod"
    Terraform   = "true"
    Project     = local.project
  }
}

terraform {
  source = "github.com/particuleio/terraform-aws-kms.git//.?ref=v1.2.0"
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


inputs = {
  description   = "EKS Secret Encryption Key for ${local.name}"
  alias         = "${local.name}_secret_encryption"
  tags          = local.tags
  policy_flavor = "eks_root_volume_encryption"
}

