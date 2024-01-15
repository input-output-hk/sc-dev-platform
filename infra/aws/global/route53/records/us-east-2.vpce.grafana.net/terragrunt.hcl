locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  project = local.environment_vars.locals.project
  tribe   = local.account_vars.locals.tribe
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53//modules/records?ref=v2.10.2"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "zones" {
  config_path = "../../zones"
}

dependency "private_link" {
  config_path = "${get_repo_root()}/infra/us-east-2/prod/grafana/private-link"
}

inputs = {

  zone_name    = dependency.zones.outputs.route53_zone_name["us-east-2.vpce.grafana.net"]
  private_zone = true

  records = [
    {
      name = "cortex-prod-13-cortex-gw"
      type = "A"
      alias = {
        name                   = dependency.private_link.outputs.endpoints.prometheus.dns_entry[0].dns_name
        zone_id                = dependency.private_link.outputs.endpoints.prometheus.dns_entry[0].hosted_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "loki-prod-006-cortex-gw"
      type = "A"
      alias = {
        name                   = dependency.private_link.outputs.endpoints.loki.dns_entry[0].dns_name
        zone_id                = dependency.private_link.outputs.endpoints.loki.dns_entry[0].hosted_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "tempo-prod-04-cortex-gw"
      type = "A"
      alias = {
        name                   = dependency.private_link.outputs.endpoints.tempo.dns_entry[0].dns_name
        zone_id                = dependency.private_link.outputs.endpoints.tempo.dns_entry[0].hosted_zone_id
        evaluate_target_health = true
      }
    }
  ]
}
