include "root" {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "../../modules/grafana-cloud"
}

inputs = {
  stack_name = "lacewallet"
  region = "us"
  path_to_sops = "${get_repo_root()}/nix/metal/encrypted/grafana-cloud-api.json"
}
