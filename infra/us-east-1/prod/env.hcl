# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  aws_region  = "us-east-1"
  environment = "prod"
  project     = "scde"
  # This will generate A records for these domains pointing to Traefik's ELB
  hostnames   = ["*.test.scdev.aws.iohkdev.io", "*.marlowe.iohk.io"]
  cidr_prefix = "10.30"
}
