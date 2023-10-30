# Set common variables for the Kubernetes cluster. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  version      = "1.26"
  name         = "blue"
  cluster_name = "${local.env_vars.locals.project}-${local.env_vars.locals.environment}-${local.env_vars.locals.aws_region}-${local.name}"
}
