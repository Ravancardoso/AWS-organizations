# ------------------------------------------------------------------
# 1. BUCKET S3 CLOUDTRAIL


resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-logs-${var.organization_name}-${data.aws_organizations_organization.current.master_account_id}" 
  acl    = "log-delivery-write" 

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Bloqueio de Acesso Público
 
  s3_block_public_access {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  versioning {
    enabled = true # Opcional, mas altamente recomendado para logs de auditoria
  }
  
  # Adiciona as tags definidas em variables.tf
  tags = var.tags 
}

# CloudTrail logs.
data "aws_iam_policy_document" "cloudtrail_s3_access" {
  statement {
    sid = "AWSCloudTrailWriteAccess"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.cloudtrail_logs.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_s3_access.json
}

output "cloudtrail_bucket_arn" {
  description = "ARN do bucket S3 centralizado para logs do CloudTrail."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}