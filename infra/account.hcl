# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "dapps-world"
  aws_account_id = "677160962006"
# aws_caller_arn = get_aws_caller_identity_arn()
  aws_profile      = "dapps-world"
  name             = "scde"
  project          = "scde"
  tribe            = "smartcontracts"
  tf_bucket_region = "us-east-1"
  # Allow users to access k8s over aws_auth config
  users = [
    # SRE
    "olaniyi.oshunbote",
    "shea.levy",
    "daniel.thagard",
    "rene.barbosa",
    "alexsander.falcucci",
    "fenton.haslam",
  ]
  domain = "dapps.aws.iohkdev.io"
}
