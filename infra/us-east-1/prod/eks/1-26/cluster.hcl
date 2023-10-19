# Set common variables for the Kubernetes cluster. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  namespaces  = ["preprod-prod", "mainnet-prod"]
  clustername = "${local.project}-${local.environment}-${local.aws_region}"

  # This will generate A records for these domains pointing to Traefik's ELB
  hostnames = ["*.test.scdev.aws.iohkdev.io"]
}
