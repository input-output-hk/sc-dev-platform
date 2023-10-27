module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.5.0"

  for_each = var.domains

  domain_name               = each.key
  zone_id                   = each.value
  subject_alternative_names = ["*.${each.key}"]
  wait_for_validation       = var.wait_for_validation
}

