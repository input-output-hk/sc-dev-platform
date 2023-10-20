image:
  tag: "v3.0"

experimental:
  kubernetesGateway:
    enabled: true

ports:
  web:
    redirectTo: websecure

service:
  annotations:
    "service.annotations.service.beta.kubernetes.io/aws-load-balancer-type": "external"
    "service.annotations.service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
    "service.annotations.service.beta.kubernetes.io/aws-load-balancer-name": "traefik"
    "service.annotations.service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
    "external-dns.alpha.kubernetes/hostname": "${hostnames}"