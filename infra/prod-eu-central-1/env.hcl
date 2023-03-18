# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  aws_region = "eu-central-1"
  environment = "prod"
  project     = "lace"
  namespaces =  [ "preprod-prod", "mainnet-prod", "preview-prod" ]
  clustername = "${local.project}-${local.environment}-${local.aws_region}"
}
