output "acm_certificate_arns" {
  value = values(module.acm)[*].acm_certificate_arn
}