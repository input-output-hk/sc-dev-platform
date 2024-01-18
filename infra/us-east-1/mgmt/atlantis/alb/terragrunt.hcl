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
  name        = "atlantis-${local.env}-${local.tribe}-alb"

  atlantis_port = 4141
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb?ref=v9.4.1"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "ec2" {
  config_path = "../ec2"
}

dependency "acm" {
  config_path = "../acm"
}

dependency "security_group" {
  config_path = "../security-group"
}

dependency "key_pair" {
 config_path = "../key-pair"
}

inputs = {
    name = local.name
    vpc_id = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.public_subnets
    
    enable_delete_protection = false

    security_group_ingress_rules = {
        all_http = {
          from_port   = 80
          to_port     = 82
          ip_protocol = "tcp"
          description = "HTTP web traffic"
          cidr_ipv4   = "0.0.0.0/0"
        }
        all_https = {
          from_port   = 443
          to_port     = 445
          ip_protocol = "tcp"
          description = "HTTPS web traffic"
          cidr_ipv4   = "0.0.0.0/0"
        }
    }
    security_group_egress_rules = {
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = dependency.vpc.outputs.vpc_cidr_block
        }
  }

  listeners = {
    http-https-redirect = {
      port    = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = dependency.acm.outputs.acm_certificate_arn
    }
  }

  target_groups = {
    atlantis = {
      name             = "atlantis"
      backend_protocol = "HTTP"
      port             = local.atlantis_port
      target_type      = "instance"
      target_id        = dependency.ec2.outputs.id
      load_balancing_cross_zone_enabled = true
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = local.atlantis_port
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  }

  route53_records = {
    A = {
      name    = "atlantis"
      type    = "A"
      zone_id = "Z10147571DRRDCJXSER5Y"
    }
    AAA = {
      name    = "atlantis"
      type    = "AAAA"
      zone_id = "Z10147571DRRDCJXSER5Y"
    }
  }

}

