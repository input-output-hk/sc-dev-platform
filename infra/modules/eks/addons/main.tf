module "node_local_dns" {
  count   = try(var.eks_addons.node_local_dns, true) ? 1 : 0
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.eks_addons.node_local_dns.chart
  chart_version    = local.eks_addons.node_local_dns.chart_version
  repository       = local.eks_addons.node_local_dns.repository
  description      = local.eks_addons.node_local_dns.description
  namespace        = local.eks_addons.node_local_dns.namespace
  create_namespace = local.eks_addons.node_local_dns.create_namespace
  values           = local.eks_addons.node_local_dns.values
  wait             = local.helm_wait
}

module "eks_addon_aws_ebs_csi_driver_iam_role" {
  count   = try(var.eks_addons.enable_aws_ebs_csi_driver, true) ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = "${var.cluster_name}-AmazonEBSCSIDriver"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "eks_addon_aws_ebs_csi_driver" {
  count   = try(var.eks_addons.enable_aws_ebs_csi_driver, true) ? 1 : 0
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.eks_addons.aws_ebs_csi_driver.chart
  chart_version    = local.eks_addons.aws_ebs_csi_driver.chart_version
  repository       = local.eks_addons.aws_ebs_csi_driver.repository
  description      = local.eks_addons.aws_ebs_csi_driver.description
  namespace        = local.eks_addons.aws_ebs_csi_driver.namespace
  create_namespace = local.eks_addons.aws_ebs_csi_driver.create_namespace
  values           = local.eks_addons.aws_ebs_csi_driver.values
  wait             = local.helm_wait

  depends_on = [
    module.eks_addon_aws_ebs_csi_driver_iam_role
  ]
}

module "eks_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.9.2"

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn

  enable_aws_load_balancer_controller = try(var.eks_addons.enable_aws_load_balancer_controller, true)
  aws_load_balancer_controller        = try(var.eks_addons.aws_load_balancer_controller, local.eks_addons.aws_load_balancer_controller)

  enable_metrics_server = try(var.eks_addons.enable_metrics_server, true)
  metrics_server        = try(var.eks_addons.metrics_server, local.eks_addons.metrics_server)

  enable_cluster_autoscaler = try(var.eks_addons.enable_cluster_autoscaler, true)
  cluster_autoscaler        = try(var.eks_addons.cluster_autoscaler, local.eks_addons.cluster_autoscaler)

  enable_cert_manager                   = try(var.eks_addons.enable_cert_manager, false)
  cert_manager                          = try(var.eks_addons.cert_manager, local.eks_addons.cert_manager)
  cert_manager_route53_hosted_zone_arns = try(var.eks_addons.cert_manager.cert_manager_route53_hosted_zone_arns, local.eks_addons.cert_manager_route53_hosted_zone_arns)

  enable_external_dns            = try(var.eks_addons.enable_external_dns, false)
  external_dns                   = try(var.eks_addons.external_dns, local.eks_addons.external_dns)
  external_dns_route53_zone_arns = try(var.eks_addons.external_dns_route53_zone_arns, local.eks_addons.external_dns_route53_zone_arns)
}

resource "kubectl_manifest" "letsencrypt_issuer" {
  count     = try(var.eks_addons.enable_cert_manager, false) ? 1 : 0
  yaml_body = file("${path.module}/manifests/letsencrypt_issuer.yaml")

  depends_on = [
    module.eks_addons
  ]
}

resource "kubectl_manifest" "kube_objects" {
  yaml_body = file("${path.module}/manifests/kube-objects.yaml")

  depends_on = [
    module.eks_addons,
    module.eks_addon_kubevela_controller
  ]
}

data "kubectl_file_documents" "gateway_crds" {
  count   = try(var.eks_addons.enable_gateway_system, true) ? 1 : 0
  content = file("${path.module}/manifests/gateway_crds.yaml")
}

data "kubectl_file_documents" "gateway_system" {
  count   = try(var.eks_addons.enable_gateway_system, true) ? 1 : 0
  content = file("${path.module}/manifests/gateway_system.yaml")
}

resource "kubectl_manifest" "gateway_crds" {
  for_each  = try(var.eks_addons.enable_gateway_system, true) ? data.kubectl_file_documents.gateway_crds.0.manifests : {}
  yaml_body = each.value
}

resource "kubectl_manifest" "gateway_system" {
  for_each  = try(var.eks_addons.enable_gateway_system, true) ? data.kubectl_file_documents.gateway_system.0.manifests : {}
  yaml_body = each.value
}

module "eks_addon_traefik_load_balancer" {
  count   = try(var.eks_addons.enable_traefik_load_balancer, false) ? 1 : 0
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.eks_addons.traefik_load_balancer.chart
  chart_version    = try(var.eks_addons.traefik_load_balancer.chart_version, local.eks_addons.traefik_load_balancer.chart_version)
  repository       = try(var.eks_addons.traefik_load_balancer.repository, local.eks_addons.traefik_load_balancer.repository)
  description      = try(var.eks_addons.traefik_load_balancer.description, local.eks_addons.traefik_load_balancer.description)
  namespace        = try(var.eks_addons.traefik_load_balancer.namespace, local.eks_addons.traefik_load_balancer.namespace)
  create_namespace = try(var.eks_addons.traefik_load_balancer.create_namespace, local.helm_create_namespace)
  values           = try(var.eks_addons.traefik_load_balancer.values, local.eks_addons.traefik_load_balancer.values)
  set              = try(var.eks_addons.traefik_load_balancer.set, local.eks_addons.traefik_load_balancer.set)
  wait             = try(var.eks_addons.traefik_load_balancer.wait, local.helm_wait)

  depends_on = [
    module.eks_addons,
    kubectl_manifest.gateway_crds,
    kubectl_manifest.gateway_system
  ]
}

module "eks_addon_nginx_ingress_load_balancer" {
  count   = try(var.eks_addons.enable_nginx_ingress_load_balancer, false) ? 1 : 0
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.eks_addons.nginx_ingress_load_balancer.chart
  chart_version    = local.eks_addons.nginx_ingress_load_balancer.chart_version
  repository       = try(var.eks_addons.nginx_ingress_load_balancer.repository, local.eks_addons.nginx_ingress_load_balancer.repository)
  description      = try(var.eks_addons.nginx_ingress_load_balancer.description, local.eks_addons.nginx_ingress_load_balancer.description)
  namespace        = try(var.eks_addons.nginx_ingress_load_balancer.namespace, local.eks_addons.nginx_ingress_load_balancer.namespace)
  create_namespace = try(var.eks_addons.nginx_ingress_load_balancer.create_namespace, local.helm_create_namespace)
  values           = try(var.eks_addons.nginx_ingress_load_balancer.values, local.eks_addons.nginx_ingress_load_balancer.values)
  set              = try(var.eks_addons.nginx_ingress_load_balancer.set, local.eks_addons.nginx_ingress_load_balancer.set)
  wait             = try(var.eks_addons.nginx_ingress_load_balancer.wait, local.helm_wait)
  name             = try(var.eks_addons.nginx_ingress_load_balancer.name, local.eks_addons.nginx_ingress_load_balancer.name)

  depends_on = [
    module.eks_addons
  ]
}

module "eks_addon_internal_nginx_ingress_load_balancer" {
  count   = try(var.eks_addons.enable_internal_nginx_ingress_load_balancer, false) ? 1 : 0
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.eks_addons.internal_nginx_ingress_load_balancer.chart
  chart_version    = local.eks_addons.internal_nginx_ingress_load_balancer.chart_version
  repository       = try(var.eks_addons.internal_nginx_ingress_load_balancer.repository, local.eks_addons.internal_nginx_ingress_load_balancer.repository)
  description      = try(var.eks_addons.internal_nginx_ingress_load_balancer.description, local.eks_addons.internal_nginx_ingress_load_balancer.description)
  namespace        = try(var.eks_addons.internal_nginx_ingress_load_balancer.namespace, local.eks_addons.internal_nginx_ingress_load_balancer.namespace)
  create_namespace = try(var.eks_addons.internal_nginx_ingress_load_balancer.create_namespace, local.helm_create_namespace)
  values           = try(var.eks_addons.internal_nginx_ingress_load_balancer.values, local.eks_addons.internal_nginx_ingress_load_balancer.values)
  set              = try(var.eks_addons.internal_nginx_ingress_load_balancer.set, local.eks_addons.internal_nginx_ingress_load_balancer.set)
  wait             = try(var.eks_addons.internal_nginx_ingress_load_balancer.wait, local.helm_wait)
  name             = try(var.eks_addons.internal_nginx_ingress_load_balancer.name, local.eks_addons.internal_nginx_ingress_load_balancer.name)

  depends_on = [
    module.eks_addons
  ]
}


module "eks_addon_kubevela_controller" {
  count   = try(var.eks_addons.enable_kubevela_controller, false) ? 1 : 0
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = local.eks_addons.kubevela_controller.chart
  chart_version    = try(var.eks_addons.kubevela_controller.chart_version, local.eks_addons.kubevela_controller.chart_version)
  repository       = try(var.eks_addons.kubevela_controller.repository, local.eks_addons.kubevela_controller.repository)
  description      = try(var.eks_addons.kubevela_controller.description, local.eks_addons.kubevela_controller.description)
  namespace        = try(var.eks_addons.kubevela_controller.namespace, local.eks_addons.kubevela_controller.namespace)
  create_namespace = try(var.eks_addons.kubevela_controller.create_namespace, local.helm_create_namespace)
  values           = try(var.eks_addons.kubevela_controller.values, local.eks_addons.kubevela_controller.values)
  set              = try(var.eks_addons.kubevela_controller.set, local.eks_addons.kubevela_controller.set)
  wait             = try(var.eks_addons.kubevela_controller.wait, local.helm_wait)

  depends_on = [
    module.eks_addons
  ]
}
