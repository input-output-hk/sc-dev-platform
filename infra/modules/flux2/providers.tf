provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url    = var.github_url
    branch = var.github_branch
    http   = {
      username = var.github_user
      password = var.github_token
    }
  }
}
