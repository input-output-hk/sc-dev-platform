# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  aws_region  = "us-east-2"
  environment = "prod"
  project     = "scde"
  cidr_prefix = "10.200"
}
