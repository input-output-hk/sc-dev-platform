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
        name  = "ATLANTIS_LOG_LEVEL"
        value = "debug"
      },
      {
        name  = "ATLANTIS_REPO_ALLOWLIST"
        value = "github.com/input-output-hk/*"
      },
      {
        name : "ATLANTIS_REPO_CONFIG_JSON",
        value : jsonencode(yamldecode(file("${path.module}/server-atlantis.yaml"))),
      },
      {
        name  = "ATLANTIS_GH_APP_ID"
        value = 790667
      },
      {
        name  = "ATLANTIS_WRITE_GIT_CREDS"
        value = true
      },
      {
        name  = "ATLANTIS_ENABLE_DIFF_MARKDOWN_FORMAT"
        value = "true"
      },
    ]
    secrets = [
      {
        name      = "ATLANTIS_GH_APP_KEY"
        valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-gh-app-key-iSotd9"
      },
      # {
      #   name      = "ATLANTIS_GH_WEBHOOK_SECRET"
      #   valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-gh-webhook-secret-cwFbJy"
      # },
      {
        name      = "ATLANTIS_GH_USER_TOKEN"
        valueFrom = "arn:aws:secretsmanager:us-east-1:677160962006:secret:atlantis-github-token-Ns6xng"
      }
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
    # cluster_configuration = {
    #   execute_command_configuration = {
    #     enable_execute_command = true
    #   }

    # }
  }
  service_subnets = var.service_subnets
  vpc_id          = var.vpc_id

  # ALB
  alb_subnets             = var.alb_subnets
  certificate_domain_name = "atlantis.${var.domain_name}"
  route53_zone_id         = var.route53_zone_id
}
