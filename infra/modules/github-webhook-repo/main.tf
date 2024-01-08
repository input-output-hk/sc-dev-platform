resource "github_repository_webhook" "this" {
  count = var.create ? length(var.repositories) : 0

  repository = var.repositories[count.index]

  configuration {
    url          = var.webhook_url
    content_type = "application/json"
    insecure_ssl = false
    secret       = random_password.webhook_secret.result
  }

  events = [
    "issue_comment",
    "pull_request",
    "pull_request_review",
    "pull_request_review_comment",
  ]
}

resource "random_password" "webhook_secret" {
  length  = 32
  special = false
}
