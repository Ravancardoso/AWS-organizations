# ------------------------------------------------------------------
# 1. CHAVE KMS PARA CRIPTOGRAFIA DE LOGS CENTRALIZADOS
# ------------------------------------------------------------------

# Criação da Chave KMS
resource "aws_kms_key" "log_encryption_key" {
  description             = "Chave KMS para criptografar Logs do CloudTrail e outros serviços centralizados."
  deletion_window_in_days = 10
  multi_region            = false
  enable_key_rotation     = true # Recomendado para segurança
  
  # A política é definida abaixo para permitir acesso entre contas/serviços
  policy = data.aws_iam_policy_document.kms_key_policy.json
}

# ------------------------------------------------------------------
# 2. POLICY DA CHAVE KMS
# ------------------------------------------------------------------

# Define quem pode usar esta chave (CloudTrail, Security OU, Audit Account)
data "aws_iam_policy_document" "kms_key_policy" {
  # Declara a conta raiz da Organization como Key Admin
  statement {
    sid    = "EnableRootAccount"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_organizations_organization.current.master_account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Permite que o CloudTrail use a chave para criptografia
  statement {
    sid    = "AllowCloudTrailEncryption"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
    condition {
      # Garante que apenas a conta de Log Archive use a chave com o CloudTrail
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [aws_organizations_account.log_archive.id] 
    }
  }

  # Permite que contas de Security e Auditoria descriptografem logs
  statement {
    sid    = "AllowSecurityAccountsToDecrypt"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        # Conta de Logs
        aws_organizations_account.log_archive.arn, 
        # Conta de Auditoria
        aws_organizations_account.audit.arn
      ]
    }
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = ["*"]
  }
}

# Cria um Alias para a chave (Nome amigável)
resource "aws_kms_alias" "log_encryption_alias" {
  name          = "alias/${var.organization_name}-LogKey"
  target_key_id = aws_kms_key.log_encryption_key.key_id
}

# ------------------------------------------------------------------
# 3. ATUALIZAÇÃO NECESSÁRIA NO buckets.tf
# ------------------------------------------------------------------

# Lembre-se que você precisará atualizar o seu bucket S3 (buckets.tf) para 
# usar esta chave KMS, alterando 'sse_algorithm' para 'aws:kms' e adicionando
# 'kms_master_key_id' (Não farei essa alteração aqui, mas é o próximo passo).