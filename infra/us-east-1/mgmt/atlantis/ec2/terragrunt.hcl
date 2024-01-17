locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  region      = local.environment_vars.locals.aws_region
  project     = local.environment_vars.locals.project
  cidr_prefix = local.environment_vars.locals.cidr_prefix
  tribe       = local.account_vars.locals.tribe
  name        = "atlantis"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v5.6.0"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "security_group" {
  config_path = "../security-group"
}

dependency "key_pair" {
 config_path = "../key-pair"
}

inputs = {
   name = local.name
   instance_type = "t2.micro"

   key_name      = dependency.key_pair.outputs.key_pair_name

   ami = "ami-02aead0a55359d6ec"
   
   
   create_iam_instance_profile = true
   iam_role_description        = "IAM role for EC2 instance"
    iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    }

   subnet_id              = dependency.vpc.outputs.public_subnets[0]

  vpc_security_group_ids = [dependency.security_group.outputs.security_group_id]

    user_data = <<-EOF
      #!/bin/bash
      sudo yum update -y
      sudo yum install -y docker
      sudo service docker start
      sudo usermod -a -G docker ec2-user
    EOF

}

