# modules/monitoring
# 관측성 & 탄력성의 "AWS 레벨" 책임만 담당 (IRSA/IAM).
# 차트 설치(kube-prometheus-stack, KEDA)는 config repo(ArgoCD)가 담당 -> 여기선 helm/k8s provider 안 씀.
#
# 현재 포함:
#   - KEDA operator IRSA : booking-queue 폴링 권한 (aws-sqs-queue scaler용)
#   - YACE IRSA          : CloudWatch SQS 메트릭을 Prometheus로 들여올 권한
# 확장 예정(필요 시 같은 패턴으로 추가):
#   - Grafana CloudWatch datasource IRSA (필요 시)

locals {
  keda_role_name = "${var.name_prefix}-keda-sqs"
  yace_role_name = "${var.name_prefix}-yace-cw"
  # eks 모듈 oidc_provider_url 은 https:// 스킴이 붙어 나옴.
  # IAM 신뢰조건 키는 스킴 없는 호스트라야 해서 제거 (이미 없는 경우도 안전).
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}

# ---------------------------------------------------------------------------
# KEDA operator IRSA — SQS booking-queue 읽기
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "keda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    # oidc_host: https:// 제거된 issuer 호스트+경로
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:${var.keda_namespace}:${var.keda_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "keda" {
  name                 = local.keda_role_name
  assume_role_policy   = data.aws_iam_policy_document.keda_assume.json
  permissions_boundary = var.role_permissions_boundary_arn
  tags                 = var.tags
}

data "aws_iam_policy_document" "keda_sqs_read" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = [var.booking_queue_arn]
  }
}

resource "aws_iam_role_policy" "keda_sqs_read" {
  name   = "${local.keda_role_name}-read"
  role   = aws_iam_role.keda.id
  policy = data.aws_iam_policy_document.keda_sqs_read.json
}

# ---------------------------------------------------------------------------
# YACE IRSA — CloudWatch 읽기 (SQS 큐 깊이를 Prometheus로 노출)
# YACE Pod은 monitoring 네임스페이스에서 var.yace_service_account 이름의 SA로 동작.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "yace_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:${var.monitoring_namespace}:${var.yace_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "yace" {
  name                 = local.yace_role_name
  assume_role_policy   = data.aws_iam_policy_document.yace_assume.json
  permissions_boundary = var.role_permissions_boundary_arn
  tags                 = var.tags
}

# YACE는 CloudWatch 메트릭 조회 + 리소스 태그로 대상(SQS 큐) 자동 발견.
# 읽기 전용이라 리소스 와일드카드(*)로 충분 (CloudWatch API는 리소스 단위 제한 없음).
data "aws_iam_policy_document" "yace_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "tag:GetResources",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "yace_cloudwatch" {
  name   = "${local.yace_role_name}-read"
  role   = aws_iam_role.yace.id
  policy = data.aws_iam_policy_document.yace_cloudwatch.json
}
