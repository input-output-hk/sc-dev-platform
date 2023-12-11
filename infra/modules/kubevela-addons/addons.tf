data "kubectl_filename_list" "manifests" {
  count   = var.enable_addons ? 1 : 0
  pattern = "${var.addons_dir}/*.yaml"
}

resource "kubectl_manifest" "addons" {
  for_each  = var.enable_addons ? toset(data.kubectl_filename_list.manifests.0.matches) : toset([])
  yaml_body = file(each.value)

  depends_on = [ 
    kubernetes_manifest.traitdefinition_https_route
   ]
}
