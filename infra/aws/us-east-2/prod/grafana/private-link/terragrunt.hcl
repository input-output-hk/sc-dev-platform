locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  profile = local.account_vars.locals.aws_profile

  # Grafana Cloud
  service_names = {
    prometheus = "com.amazonaws.vpce.us-east-2.vpce-svc-0d13a270cd91a0a3a"
    loki       = "com.amazonaws.vpce.us-east-2.vpce-svc-071e7d98821c1698b"
    tempo      = "com.amazonaws.vpce.us-east-2.vpce-svc-0a830aaea99ecfc91"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc_us_east_1" {
  config_path = "${get_repo_root()}/infra/aws/us-east-1/prod/vpc"
}

dependency "vpc_us_east_2" {
  config_path = "${get_repo_root()}/infra/aws/us-east-2/prod/grafana/vpc"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc//modules/vpc-endpoints?ref=v5.1.1"
}

inputs = {
  vpc_id = dependency.vpc_us_east_2.outputs.vpc_id

  endpoints = {
    prometheus = {
      service_name        = local.service_names.prometheus
      service_type        = "Interface"
      subnet_ids          = dependency.vpc_us_east_2.outputs.private_subnets
      private_dns_enabled = true
      tags = {
        Name = "grafana-cloud-prometheus"
      }
    }
    loki = {
      service_name        = local.service_names.loki
      service_type        = "Interface"
      subnet_ids          = dependency.vpc_us_east_2.outputs.private_subnets
      private_dns_enabled = true
      tags = {
        Name = "grafana-cloud-loki"
      }
    }
    tempo = {
      service_name        = local.service_names.tempo
      service_type        = "Interface"
      subnet_ids          = dependency.vpc_us_east_2.outputs.private_subnets
      private_dns_enabled = true
      tags = {
        Name = "grafana-cloud-tempo"
      }
    }
  }

  create_security_group      = true
  security_group_name_prefix = "grafana-private-link-sg-"
  security_group_description = "Grafana Private Link Endpoint SecurityGroup"
  security_group_rules = {
    ingress_grafana_cloud = {
      description = "Enable Grafana Cloud connection from Prod VPC"
      cidr_blocks = dependency.vpc_us_east_1.outputs.private_subnets_cidr_blocks
    }
    egress_default_rule = {
      type      = "egress"
      from_port = 0
      to_port   = 65535
      protocol  = "all"
      self      = true
    }
  }
}