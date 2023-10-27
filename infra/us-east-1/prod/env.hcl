# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  aws_region  = "us-east-1"
  environment = "prod"
  project     = "scde"
  # This will be used to generate:
  # Route53: A records for these domains pointing to Traefik's ELB
  # ACM Certificates and validation DNS records (Route53)
  # IAM: Policies allowing External-DNS to execute changes on DNS records (Route53)
  route53_config = {
    "test.scdev.aws.iohkdev.io" = "Z10147571DRRDCJXSER5Y"
    "marlowe.iohk.io" = "Z0440193WFXP2UUTHQ1S"
  }
  cidr_prefix = "10.30"
}
