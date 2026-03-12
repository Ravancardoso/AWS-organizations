# KMS key for central log encryption
resource "aws_kms_key" "log_encryption_key" {
  description             = "KMS Key to encrypt CloudTrail Logs and other centralized services."
  deletion_window_in_days = 10
  multi_region            = false
  enable_key_rotation     = true

  # Key policy for cross-account and service access
  policy = data.aws_iam_policy_document.kms_key_policy.json
}

# KMS Key Policy
data "aws_iam_policy_document" "kms_key_policy" {
  # Organization root account as Key Admin
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

  # Allow CloudTrail to encrypt logs
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
      # Restrict key usage to Log Archive account for CloudTrail
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [aws_organizations_account.log_archive.id]
    }
  }

  # Allow Security/Audit accounts to decrypt logs
  statement {
    sid    = "AllowSecurityAccountsToDecrypt"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_organizations_account.log_archive.arn,
        aws_organizations_account.audit.arn
      ]
    }
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = ["*"]
  }
}

# Key Alias
resource "aws_kms_alias" "log_encryption_alias" {
  name          = "alias/${var.organization_name}-LogKey"
  target_key_id = aws_kms_key.log_encryption_key.key_id
}