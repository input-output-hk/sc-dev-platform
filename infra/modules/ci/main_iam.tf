## Setup user used by CI system ##
resource "aws_iam_user" "ci" {
  name = var.iam_user

  tags = {
    Description = "Used by Github Actions"
  }
}

resource "aws_iam_user_policy_attachment" "ci_ecr_access" {
  user       = aws_iam_user.ci.name
  policy_arn = aws_iam_policy.ci_ecr_access.arn
}

resource "aws_iam_policy" "ci_ecr_access" {
  name        = "CIECRAccess"
  description = "Provides access to CI ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Effect = "Allow",
        Resource = "*",
      },
    ]
  })
}

resource "aws_iam_openid_connect_provider" "ci" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_iam_role" "ci" {
  name = var.iam_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.ci.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          "ForAnyValue:StringLike" = {
            "token.actions.githubusercontent.com:sub" = [for repo in var.authorized_repos : "repo:${repo}:*"]
          }
        }
      },
    ]
  })

  tags = {
    Description = "Used by Github Actions"
  }
}

resource "aws_iam_role_policy_attachment" "ci_ecr_access" {
  role       = aws_iam_role.ci.name
  policy_arn = aws_iam_policy.ci_ecr_access.arn
}
