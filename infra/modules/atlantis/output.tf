# outputs.tf

output "alb" {
  description = "ALB created and all of its associated outputs"
  value       = module.atlantis.alb
}

output "cluster" {
  description = "ECS cluster created and all of its associated outputs"
  value       = module.atlantis.cluster
}

output "efs" {
  description = "EFS created and all of its associated outputs"
  value       = module.atlantis.efs
}

output "service" {
  description = "ECS service created and all of its associated outputs"
  value       = module.atlantis.service
}

output "url" {
  description = "URL of Atlantis"
  value       = module.atlantis.url
}
