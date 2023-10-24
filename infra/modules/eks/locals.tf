locals {
  cluster_addons = {
    #    aws-ebs-csi-driver = {
    #      most_recent = true
    #   }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}