data "tls_certificate" "eks" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "git" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "git_aws_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.git.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.git.url, "https://", "")}:sub"
      values   = ["repo:kenmakhanu/argo-gitactions-test:*"]
    }


    principals {
      identifiers = [aws_iam_openid_connect_provider.git.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "git_action" {
  assume_role_policy = data.aws_iam_policy_document.git_aws_oidc.json
  name               = "git-action-oidc-role"
}

resource "aws_iam_policy" "git_action" {
  name = "git-action_policy"

  policy = jsonencode({
    Statement = [{
      Action   = ["*"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
  role       = aws_iam_role.git_action.name
  policy_arn = aws_iam_policy.git_action.arn
}

output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.git_action.arn
}

