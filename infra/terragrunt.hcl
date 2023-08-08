# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # Force MFA with every run using awslogin tool: https://pypi.org/project/aws-mfa-tools/
  #  after_hook "terragrunt-read-config" {
  #    commands = ["terragrunt-read-config"]
  #    execute  = ["awslogin", "--profile", local.account_vars.locals.aws_profile]
  #  }
  #  extra_arguments "assume_role" {
  #    commands = [
  #      "init",
  #      "apply",
  #      "refresh",
  #      "import",
  #      "plan",
  #      "taint",
  #      "untaint",
  #      "destroy"
  #    ]
  #
  #    arguments = [
  #      "--terragrunt-iam-role arn:aws:iam::${local.account_id}:role/terraform"
  #    ]
  #
  #    #    env_vars = {
  #    #      TF_VAR_var_from_environment = "value"
  #    #    }
  #  }
}

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_profile  = local.account_vars.locals.aws_profile
  aws_region   = local.environment_vars.locals.aws_region
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "skip"
  contents  = <<EOF
  provider "aws" {
    region = "${local.aws_region}"
    profile = "${local.aws_profile}"
    allowed_account_ids = ["${local.account_id}"]
    # Use assume role instead named profile / Create Role manually
    #assume_role {
    #    role_arn = "arn:aws:iam::${local.account_id}:role/terragrunt"
    #  }
    # Only these AWS Account IDs may be operated on by this template
}
EOF
}


# Generate an tfenv version constraint file
generate "tfenv" {
  path              = ".terraform-version"
  if_exists         = "skip"
  disable_signature = true
  contents          = <<EOF
1.3.0
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", "")}tf-state-${local.account_name}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
    profile        = local.aws_profile
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.environment_vars.locals,
  local.environment_vars.locals,
)
