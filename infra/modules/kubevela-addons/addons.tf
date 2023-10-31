data "kubectl_filename_list" "manifests" {
    pattern = "./addons/*.yaml"
}

resource "kubectl_manifest" "addons" {
    count     = length(data.kubectl_filename_list.manifests.matches)
    yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
}
