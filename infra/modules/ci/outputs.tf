output "ecr_repo_urls" {
  value       = { for k, r in aws_ecr_repository.ci : k => r.repository_url }
  description = "A map of ECR repositories to their respective URLs"
}

output "iam_role_arn" {
  value       = aws_iam_role.ci.arn
  description = "The ARN of the role that the CI service should assume"
}
