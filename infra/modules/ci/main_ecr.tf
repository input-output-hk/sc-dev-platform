## Create ECR repositories for publishing images ##
resource "aws_ecr_repository" "ci" {
  for_each             = toset(var.ecr_repos)
  name                 = each.key
  image_tag_mutability = "MUTABLE"
}
