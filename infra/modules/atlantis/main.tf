module "atlantis" {
  source = "terraform-aws-modules/atlantis/aws"

  name = var.name

  # ECS Container Definition
  atlantis = {
    environment = [
      {
        name  = "ATLANTIS_GH_USER"
        value = "Fentonhaslam"
      },
      {
        name  = "ATLANTIS_REPO_ALLOWLIST"
        value = "github.com/input-output-hk/*"
      },
    ]
    secrets = [
      {
        name      = "ATLANTIS_GH_TOKEN"
        valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-github-token-Ns6xng"
      },
      {
        name      = "ATLANTIS_GH_WEBHOOK_SECRET"
        valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-github-webhook-secret-5LsH5r"
      },
    ]
  }

  # ECS Service
  service = {
    task_exec_secret_arns = var.task_exec_secret_arns
    # Provide Atlantis permission necessary to create/destroy resources
    tasks_iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    }

    assign_public_ip = true
  }
  service_subnets = var.service_subnets
  vpc_id          = var.vpc_id

  # ALB
  alb_subnets             = var.alb_subnets
  certificate_domain_name = "atlantis.${var.domain_name}"
  route53_zone_id         = var.route53_zone_id
}

