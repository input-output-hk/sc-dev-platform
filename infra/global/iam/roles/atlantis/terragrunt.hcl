locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project = local.environment_vars.locals.project
  tribe   = local.account_vars.locals.tribe

  role_name                 = "AtlantisDeploymentRole"
  atlantis_serviceaccount   = "default:atlantis"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-eks-role?ref=v5.30.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  create_role                = true
  role_name                  = local.role_name
  allow_self_assume_role     = true
  assume_role_condition_test = "StringLike"
  cluster_service_accounts = {
    "scde-dev-us-east-1"       = [local.atlantis_serviceaccount]
  }
  role_policy_arns = {
    AmazonAdminAccess   = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
}
