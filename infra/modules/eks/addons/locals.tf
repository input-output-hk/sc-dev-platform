locals {

  helm_wait             = true
  helm_create_namespace = true

  eks_addons = {
    aws_load_balancer_controller = {}
    metrics_server               = {}
    cluster_autoscaler           = {}
    cert_manager                 = {}
    external_dns                 = {}
    node_local_dns = {
      chart            = "node-local-dns"
      chart_version    = "2.0.3"
      repository       = "https://charts.deliveryhero.io"
      description      = "A Helm chart for Node Local DNS"
      namespace        = "kube-system"
      create_namespace = "false"
      values           = []
      set              = []
    }
    aws_ebs_csi_driver = {
      chart            = "aws-ebs-csi-driver"
      chart_version    = "2.24.0"
      repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
      description      = "A Helm chart for AWS EBS CSI Driver"
      namespace        = "kube-system"
      create_namespace = "false"
      values = [
        <<-EOF
        controller:
          serviceAccount:
            create: true
            annotations:
              eks.amazonaws.com/role-arn: "${module.eks_addon_aws_ebs_csi_driver_iam_role.0.iam_role_arn}"

        storageClasses:
          - name: ebs-sc
            annotations:
              storageclass.kubernetes.io/is-default-class: "false" 
            parameters:
              fsType: ext4
              type: gp3
              encrypted: "true"
            allowVolumeExpansion: true
            reclaimPolicy: Delete
            volumeBindingMode: WaitForFirstConsumer
        EOF
      ]
      set = []
    }
    traefik_load_balancer = {
      chart         = "traefik"
      chart_version = "25.0.0"
      repository    = "https://traefik.github.io/charts"
      description   = "A Traefik based Kubernetes ingress controller"
      namespace     = "traefik"
      values        = []
      set           = []
    }
    nginx_ingress_load_balancer = {
      chart         = "ingress-nginx"
      chart_version = "4.8.4"
      repository    = "https://kubernetes.github.io/ingress-nginx"
      description   = "NGINX Ingress Controller for Kubernetes"
      namespace     = "ingress-nginx"
      values        = []
      set           = []
    }
    internal_nginx_ingress_load_balancer = {
      chart         = "ingress-nginx"
      chart_version = "4.8.4"
      repository    = "https://kubernetes.github.io/ingress-nginx"
      description   = "Internal NGINX Ingress Controller for Kubernetes"
      namespace     = "ingress-nginx"
      values        = []
      set           = []
    }
    kubevela_controller = {
      chart         = "vela-core"
      chart_version = "1.9.6"
      repository    = "https://kubevela.github.io/charts"
      description   = "A Helm chart for KubeVela core"
      namespace     = "vela-system"
      values        = []
      set           = []
    }
  }
}
