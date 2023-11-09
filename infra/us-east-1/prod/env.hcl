# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  aws_region  = "us-east-1"
  environment = "prod"
  project     = "scde"
  # This is used to generate:
  # Route53: Records pointing to Traefik's LoadBalancer
  # ACM: Certificates and DNS Records to validate certificates
  # IAM: Policies allowing External-DNS to use Route53
  route53_config = {
    "scdev.aws.iohkdev.io"      = "Z10147571DRRDCJXSER5Y"
    "test.scdev.aws.iohkdev.io" = "Z10147571DRRDCJXSER5Y"
    "demo.scdev.aws.iohkdev.io" = "Z10147571DRRDCJXSER5Y"
    "prod.scdev.aws.iohkdev.io" = "Z10147571DRRDCJXSER5Y"
    "marlowe.iohk.io"           = "Z0440193WFXP2UUTHQ1S"
    "runner.marlowe.iohk.io"    = "Z0440193WFXP2UUTHQ1S"
  }
  cidr_prefix = "10.30"
  # New VPC configuration
  new_vpc_cidr = "10.100.0.0/16"
  new_vpc_public_subnets = [
    "10.100.0.0/20",
    "10.100.16.0/20",
    ]
}
