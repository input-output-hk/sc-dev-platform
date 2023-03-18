variable "authorized_repos" {
  type        = list(string)
  description = "A list of repository names (org/my-repo) allowed to assume the CI role"
}

variable "iam_user" {
  type        = string
  description = "The name of the IAM user to create for CI access"
}

variable "iam_role" {
  type        = string
  description = "The name of the role that the CI service should assume"
}

variable "ecr_repos" {
  type        = list(string)
  description = "A list of ECR repositories to create"
}
