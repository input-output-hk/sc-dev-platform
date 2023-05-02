variable "github_url" {
  description = "Name of the GitHub repo"
  type        = string
  default     = "https://github.com/input-output-hk/sc-dev-platform.git"
}

variable "github_user" {
  description = "GitHub username"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub user Personal Access Token (PAT)"
  type        = string
  sensitive   = true
}

variable "github_branch" {
  description = "GitHub Branch to run Continuous Deployment of K8s manifests from"
  type        = string
  default     = "init-infra"
}