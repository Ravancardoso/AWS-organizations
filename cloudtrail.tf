# ------------------------------------------------------------------
# 1. RECURSO PRINCIPAL: AWS CLOUDTRAIL (Organization Trail)
# ------------------------------------------------------------------

# Este recurso criará o CloudTrail em TODAS as contas da sua AWS Organization.
# O log de eventos será enviado para o bucket S3 centralizado.
resource "aws_cloudtrail" "organization_trail" {
  name                          = "${var.organization_name}-Organization-Trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id # Referencia o bucket criado em buckets.tf
  is_organization_trail         = true # ESSENCIAL: Cria o Trail em todas as contas.
  is_multi_region_trail         = true # Recomendado: Rastreia eventos em todas as regiões AWS
  include_global_service_events = true # Recomendado: Inclui eventos globais (IAM, S3, CloudFront)

  # Permite que o CloudTrail use logs do CloudWatch para alertas em tempo real
  cloud_watch_logs_role_arn = aws_iam_role.cloudtrail_logs.arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
}

# ------------------------------------------------------------------
# 2. RECURSOS DE SUPORTE: IAM E CLOUDWATCH
# ------------------------------------------------------------------

# 2.1. GRUPO DE LOGS NO CLOUDWATCH (para visualização e alertas)
resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/${var.organization_name}-Organization-Trail"
  retention_in_days = 90 # Configuração de retenção para logs (ajuste conforme necessário)
}

# 2.2. ROLE IAM PARA PERMITIR QUE CLOUDTRAIL ESCREVA NO CLOUDWATCH
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    sid     = "CloudTrailAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_logs" {
  name               = "CloudTrail-CloudWatch-Access-Role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

# 2.3. POLICY IAM PARA PERMITIR QUE CLOUDTRAIL ESCREVA NO LOG GROUP
data "aws_iam_policy_document" "cloudtrail_put_logs" {
  statement {
    sid    = "CloudTrailAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.cloudtrail_logs.arn]
  }
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name   = "CloudTrail-PutLogs-Policy"
  role   = aws_iam_role.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_put_logs.json
}