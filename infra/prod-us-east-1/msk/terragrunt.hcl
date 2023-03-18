include "root" {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "../../modules/msk"
}

# VPC as dependency
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_cidr_blocks = [ "10.10.108.0/24", "10.10.109.0/24", "10.10.110.0/24"]
}
