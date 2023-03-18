data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_user" "user" {
  for_each = toset(var.usernames)
  name = each.value

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_iam_group" "developers" {
  name = var.group_name
  path = "/lace/"
}

resource "aws_iam_group_membership" "team" {
  name = "tf-testing-group-membership"

  users = toset([for user in aws_iam_user.user : user.name])
  group = aws_iam_group.developers.name
}

resource "aws_iam_group_policy" "this" {
  name  = "devs_assume_role_policy"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Resource = aws_iam_role.role.arn
      },
      {
        Action = "eks:DescribeCluster",
        Effect = "Allow",
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_access_key" "access_key" {
  for_each = aws_iam_user.user
  user = each.value.name
}
