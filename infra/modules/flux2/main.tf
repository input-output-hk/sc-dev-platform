resource "flux_bootstrap_git" "this" {
  path                   = "clusters/my-cluster"
  network_policy         = true
  # kustomization_override = file("${path.module}/kustomization.yaml")
}