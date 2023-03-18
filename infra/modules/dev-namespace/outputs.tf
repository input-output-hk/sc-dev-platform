 output "iam_access_keys" {
  value       = aws_iam_access_key.access_key
  description = "Generated access keys"
  sensitive   = true
}

output "iam_role_arn" {
  value       = aws_iam_role.role.arn
  description = "The ARN of the role that the CI service should assume"
}
