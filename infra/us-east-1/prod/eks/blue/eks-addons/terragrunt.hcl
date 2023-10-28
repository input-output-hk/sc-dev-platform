locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.environment_vars.locals.aws_region
  domains = local.environment_vars.locals.route53_config
  profile = local.account_vars.locals.aws_profile

  route53_zone_arns = [for zone_id in values(local.domains) : "arn:aws:route53:::hostedzone/${zone_id}"]
  traefik_hostnames = [for domain in keys(local.domains) : "*.${domain}"]
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/input-output-hk/sc-dev-platform.git//infra/modules/eks/addons?ref=464f65bea1f574f26d58456701547a2aee31fa8c"
}

dependency "eks" {
  config_path = "../eks"
}

dependency "acm" {
  config_path = "../../../acm"
}

inputs = {

  aws_profile                        = local.profile
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_version                    = dependency.eks.outputs.cluster_version
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn

  eks_addons = {

    # Cluster Autoscaler
    cluster_autoscaler = {
      set = [{
        name  = "extraArgs.scale-down-utilization-threshold"
        value = "0.7"
      }]
    }

    # External-DNS
    enable_external_dns            = true
    external_dns_route53_zone_arns = local.route53_zone_arns
    external_dns = {
      values = [
        <<-EOT
        env:
          # Don't change anything, useful for debugging purposes.
          - name: EXTERNAL_DNS_DRY_RUN
            value: "0"
        txtOwnerId: "${dependency.eks.outputs.cluster_name}"
        EOT
      ]
    }
    
    # Traefik Load Balancer
    enable_traefik_load_balancer = true
    traefik_load_balancer = {
      values = [
        <<-EOT
        image:
          tag: "v3.0"

        experimental:
          kubernetesGateway:
            enabled: true
            namespacePolicy: All
            certificate:
              group: "core"
              kind: "Secret"
              name: "self-signed-tls"

        ports:
          web:
            redirectTo:
              port: websecure
              priority: 10

        service:
          annotations:
            "service.beta.kubernetes.io/aws-load-balancer-type": "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance"
            "service.beta.kubernetes.io/aws-load-balancer-name": "traefik"
            "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "ssl"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "${join(",", dependency.acm.outputs.acm_certificate_arns)}"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": "websecure"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy": "ELBSecurityPolicy-TLS13-1-2-2021-06"
            "external-dns.alpha.kubernetes.io/hostname": "${join(",", local.traefik_hostnames)}"
            "external-dns.alpha.kubernetes.io/aws-weight": "100"
            "external-dns.alpha.kubernetes.io/set-identifier": "traefik-blue"

        extraObjects:
          - apiVersion: v1
            data:
              tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURrekNDQW5zQ0ZGT2N5R0hRaGVJSTUxeGRnRzJRbTJpQ1hBa1NNQTBHQ1NxR1NJYjNEUUVCQ3dVQU1JR0YKTVFzd0NRWURWUVFHRXdKQ1VqRVFNQTRHQTFVRUNBd0hVR0Z5WVdsaVlURVVNQklHQTFVRUJ3d0xTbTloYnlCUQpaWE56YjJFeEdUQVhCZ05WQkFvTUVFMXZaSFZ6SUVOeVpXRjBaU0JNVEVNeER6QU5CZ05WQkFzTUJrUmxkazl3CmN6RWlNQ0FHQTFVRUF3d1pkSEpoWldacGF5NTBjbUZsWm1sckxuTjJZeTVzYjJOaGJEQWVGdzB5TXpFd01qY3kKTXpVeU5EVmFGdzB6TXpFd01qUXlNelV5TkRWYU1JR0ZNUXN3Q1FZRFZRUUdFd0pDVWpFUU1BNEdBMVVFQ0F3SApVR0Z5WVdsaVlURVVNQklHQTFVRUJ3d0xTbTloYnlCUVpYTnpiMkV4R1RBWEJnTlZCQW9NRUUxdlpIVnpJRU55ClpXRjBaU0JNVEVNeER6QU5CZ05WQkFzTUJrUmxkazl3Y3pFaU1DQUdBMVVFQXd3WmRISmhaV1pwYXk1MGNtRmwKWm1sckxuTjJZeTVzYjJOaGJEQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUltQgorOWRrM3QyVEZsY3FGSktJUk1ndm5OYTlVbE9VS1ZGRGR2NTF4TGZzblQya3hIeGEycGNIV3hacE9LQWIrQlZnCm90cFBnWWV2K2tLRUEvZVpPM0xCcFpVcHdCdTUzd2N2UFpBQ0hvR2JUTGF5NkhBbHNHZjFXUEw3d2hYaWRpSmQKUXUvNVB0clV0Z3RzMFBvVklqRURjZmVVWVlOa2l1eFVrUW9IUm5DSkx6aTNSdGI4WExVTmhIc21ubTB5V2QzRApIQTUxbStmWkFNWWpPekQzd1BLdTMrU3U1VVc1eW9RWi9kSEpVY0VIM092anRYcWhoLyt0MEdUSStNSFRmcWlUCjVUYkoya3liQjNlRzZMNDg5WkFYME0xT2ZoM3JNTHVhQStyeSs0SzdFS1NjYlNKY1NUYjNqMWF2VUlUb1NCdmYKOTJBKzd3YXhkR21PT3hWYnMya0NBd0VBQVRBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUY1U3p2dUFoQ0o4SApUN1dqV3Rva2JZQ1ZUK3ZNZEcyVE8rQWo0WWRSNFZXbEhQbUl4OTNKeFZGSDFhUGlZS3lESnBES0VscjhhQys0CkRHWVFEcWRiT0VRNkM3VVVGM1BLa1NzWVVvNExTV05tNFRHYmZ5TVBudU1kZWkyRGFsMmw5L1dBeSs4QXFCTFEKQ2l6eHFCUlBGSjI4TDZ2QmVXYXFrczRydmx4V1ZzRVhFVWttcXMzNWtHTldsSmhRdjBZVkZMaHAwa3R3R3NtYgo2SzFQK3JPTldRN3ZpV2xFMmlYOGxjUS9mMit2WTFpcmxueDJNK1RZRkRjSE5Vd3FiSmpMM2xqSVozdW4yTzF5CkRaZEplQmUxeUZRMjFIUGViTENQc1ErRTd0T2xjVHNCVjJPMVhmZnBlZVJ1TFhtM1RaQzhHMHdiYWJiNWR6R1kKeTIxVlZGNkpKQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
              tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2Z0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRQ0pnZnZYWk43ZGt4WlgKS2hTU2lFVElMNXpXdlZKVGxDbFJRM2IrZGNTMzdKMDlwTVI4V3RxWEIxc1dhVGlnRy9nVllLTGFUNEdIci9wQwpoQVAzbVR0eXdhV1ZLY0FidWQ4SEx6MlFBaDZCbTB5MnN1aHdKYkJuOVZqeSs4SVY0bllpWFVMditUN2ExTFlMCmJORDZGU0l4QTNIM2xHR0RaSXJzVkpFS0IwWndpUzg0dDBiVy9GeTFEWVI3SnA1dE1sbmR3eHdPZFp2bjJRREcKSXpzdzk4RHlydC9rcnVWRnVjcUVHZjNSeVZIQkI5enI0N1Y2b1lmL3JkQmt5UGpCMDM2b2srVTJ5ZHBNbXdkMwpodWkrUFBXUUY5RE5UbjRkNnpDN21nUHE4dnVDdXhDa25HMGlYRWsyOTQ5V3IxQ0U2RWdiMy9kZ1B1OEdzWFJwCmpqc1ZXN05wQWdNQkFBRUNnZ0VBQ1FJc2d4UjNLMUgzRFRmVENEU0lPUXN4ZmJvQ2VqcERLTEZBU3ZSaE1tRjgKZmF6ZE9INWxRcTYzTDNVdVFnTURFamQyQTlKZ25JaVJYeWt4NzFjcEYyQUxYb1hSTVovUU5qTEltRFlqVkg5ZAptN3lGME04UFN3ZytUeERpU3JlKzRJcDJsNjBmQ293VDd4U3ViaXZUUlIzQ0tpT2M3ZFE0Njdtd2xOVWNMc1FkCmJRRW5NRTNLU01ScktiTy9tNTZXNWNTbVJTZzBFK0U0dkx6dnMxcExPUkpmelpkcFpyOEU3VWR4Z1NKMUF0OHYKU2t6UnREWXBEQTVjSVVBZE1SU3VwclNmRWdGQmlvSlZTeE5CVCtqSVRvakYxeWN2RkZJTkxkTGF0QmxWeW9jdgp2amR4OWw5Q3hkT2pOZ3htVGVpZGpkaDE0YVJqdWRhYXE1KzllMkpRbVFLQmdRREJkeE8xQTMyNkU3Y1hmYzN4CjYyL2haY0U1QU5OQTVnV2tLaXA1MXRRUUhwaDRlajk0K2Z0SEFkdVVVZ25mcWxsdFdBWGxhRFVnTHpaU3pGUzYKSXJYbm1BV29JcHF6anI0TE5EL1RESzFxSzhGQ1Q0OFF4K2NuTklRNmk1VlVHeGJobDYwZVlERnBVRFg0RUxycgpQRFJHMEZZZmNqUXZmbWdXNDNxNDdPQVJyUUtCZ1FDMTlJWXhXdjVvQzVQSXR5eExXeFRBaUxxNDRVMzQzQUZxClJBdFZCcW9yb2xxOTM4TzBFekhSYzJBR0VkVFhvK1E4M2hBeUYvb0hnY3dPdnZ5ekxVVG1JbFppSU5YRlRHOGoKV2pyODBmWVdMaHE2K2ROeWZramYwOUlORExrbnNqdkxSaHFkVTBnTmEzeWg0QnZKWitSTnRQUmhQWG5scGlPWApwUDlDYVYzNExRS0JnRWw3TE9VSDJtMGVwK0FvVEZ5aWkvQVVjZnR3c014cGthTDAwUVZONzJYZitSRnBmVW81CnlKTUR4WjdrT2hQVjQvbUFBVjFNNDBEQ0xlUHM4QkZ5dFp5dFJSakRhL2JmTkplVTFOa1lhNVZ6NFFlS3FGQTcKWFRTcTRiNUszZ0QvK1FUZVUwYkNTb0l4a1E0VGJLdUVSbWJQSXFiMi9aTThjOVNkdWpNYTVWQlJBb0dCQUpzdQp2enhjMU5rNzlvQ2E2S1lrT2lDeS9EMHR1dWhpQ3JyczZaVk1wOW1yRUNVY01MYm1IL2o0bzQ3SnFuTjNqZkx6Cm1YQi96bmlVbE1xR3pOS3I2elV6VitVOUI5VExpWVhuTUtQckZpeDRpY2VweGxMQnJibG4ySi9VbUIxby8ySXcKbWdaUHZ3WGpCRnF5M2ovNTRWYjgyK2dMSEdsbU5yamd1ZXVVSGRiSkFvR0JBTFc5L1pVRGsyOXRtYUFLekxBYQptZitRYnVEcGZ3TU1NQVZjVzJ1aGk3c3ZyQndOK2dEUGVWdldJLzB2UnU0NDNmWHRSYnVYZXhFL0l5bWUxN3g1CkhKV2dwYVB4NEZPSFRtdVZFWHU2a0NLMi81dDRUOVJGc2JxemdMY21lNE5vUjQyb2U0SVM5SmZHNXN2SHdvRlgKcmtBcXRlb0Q3WkI1a1pOZnIrZUYwS2NOCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
            kind: Secret
            metadata:
              name: self-signed-tls
              namespace: traefik
            type: kubernetes.io/tls 
        EOT
      ]
    }

    # KubeVela Controller
    enable_kubevela_controller = true
  }
}
