data "aws_caller_identity" "current" {}

# OIDC Trust Policy
data "aws_iam_policy_document" "gha_oidc_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:CLD-05/team5-ticket-app:*",
        "repo:CLD-05/team5-ticket-infra:*",
        "repo:CLD-05/team5-ticket-config:*"
      ]
    }
  }
}

resource "aws_iam_role" "gha" {
  name                 = "team5-gha-${var.environment}-role"
  permissions_boundary = "arn:aws:iam::194722398200:policy/TeamRuntimeBoundary"
  assume_role_policy   = data.aws_iam_policy_document.gha_oidc_assume.json

  tags = {
    Name = "team5-gha-${var.environment}-role"
    Team = "team5"
  }
}

resource "aws_iam_role_policy_attachment" "gha_admin" {
  role       = aws_iam_role.gha.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
