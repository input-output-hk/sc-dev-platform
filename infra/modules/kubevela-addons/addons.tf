data "kubectl_filename_list" "manifests" {
  pattern = "${var.addons_dir}/*.yaml"
}

resource "kubectl_manifest" "addons" {
  for_each  = toset(data.kubectl_filename_list.manifests.matches)
  yaml_body = try(file(each.value), null)
}
