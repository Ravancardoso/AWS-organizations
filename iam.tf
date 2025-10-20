# ------------------------------------------------------------------
# 1. SCP: PROIBIR RECURSOS EM REGIÕES NÃO PERMITIDAS (REGION DENIAL)
# ------------------------------------------------------------------

# Esta política SCP nega qualquer ação de serviço, exceto aquelas de serviços 
# globalmente necessários (IAM, Organizations, CloudFront, etc.), em qualquer região 
# que não esteja na lista de 'allowed_regions'.

data "aws_iam_policy_document" "region_denial" {
  statement {
    sid       = "DenyRegions"
    effect    = "Deny"
    not_actions = [
      # Serviços globais que não têm uma região específica para negar:
      "iam:*",
      "organizations:*",
      "sso:*",
      "cloudfront:*",
      "route53:*",
      "waf-regional:*",
    ]
    resources = ["*"]
    
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = var.allowed_regions # Puxa do variables.tf
    }
  }
}

resource "aws_organizations_policy" "region_denial" {
  name        = "SCP-Region-Denial"
  description = "Nega a criação de recursos fora das regiões permitidas."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_denial.json
}

# Anexa a SCP à OU de Workloads
resource "aws_organizations_policy_attachment" "region_denial_workloads" {
  policy_id = aws_organizations_policy.region_denial.id
  target_id = aws_organizations_organizational_unit.workloads.id 
  # O ID da OU 'workloads' vem do seu organizations.tf
}

# ------------------------------------------------------------------
# 2. SCP: OBRIGAR USO DE TAGS (TAGGING ENFORCEMENT)
# ------------------------------------------------------------------

# Esta SCP obriga que recursos com a tag 'Custo' sejam criados.
# Isso é crucial para o controle de custos e governança.

data "aws_iam_policy_document" "mandatory_tags" {
  statement {
    sid    = "EnforceCostTag"
    effect = "Deny"
    actions = [
      "ec2:RunInstances",
      "s3:CreateBucket",
      "rds:CreateDBInstance",
      "lambda:CreateFunction"
      # ... adicione outras ações de criação de recursos importantes
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/Custo" # Garante que a tag 'Custo' exista
      values   = ["true"]
    }
  }
}

resource "aws_organizations_policy" "mandatory_tags" {
  name        = "SCP-Mandatory-Tags"
  description = "Obriga a inclusão da tag 'Custo' ao criar recursos selecionados."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.mandatory_tags.json
}

# Anexa a SCP à OU de Workloads (onde os desenvolvedores criam recursos)
resource "aws_organizations_policy_attachment" "mandatory_tags_workloads" {
  policy_id = aws_organizations_policy.mandatory_tags.id
  target_id = aws_organizations_organizational_unit.workloads.id
}