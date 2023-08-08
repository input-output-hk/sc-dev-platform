# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  aws_region = "us-east-1"
  environment = "prod"
  project     = "dapps"
}
