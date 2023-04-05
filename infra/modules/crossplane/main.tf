module "aws_crossplane" {
  source = "github.com/projectkerberus/terraform-kerberus-crossplane.git//modules/aws-crossplane?ref=v0.2.1"
}

module "crossplane" {
  source = "github.com/projectkerberus/terraform-kerberus-crossplane.git?ref=v0.2.1"

  depends_on = [
    module.aws_crossplane
  ]

  path_kubeconfig = var.path_kubeconfig

  crossplane_namespace = var.crossplane_namespace

  crossplane_providers = {
    "aws-provider": module.aws_crossplane.provider,
    "sql-provider": file("sql-provider.yaml")
  }

  crossplane_secrets   = {
    "aws-creds" : module.aws_crossplane.secret
  }
}

data "kubectl_file_documents" "crossplane_manifests" {
    content = templatefile("manifests.yaml.tmpl", {
        namespace = var.crossplane_namespace,
        vpcId = var.eks_vpc_id
    })
}

resource "kubectl_manifest" "crossplane_resources" {
    depends_on = [
      module.crossplane
    ]
    for_each  = data.kubectl_file_documents.crossplane_manifests.manifests
    yaml_body = each.value
}
