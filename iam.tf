# SCP: Deny resource creation outside allowed regions (excludes global services)

data "aws_iam_policy_document" "region_denial" {
  statement {
    sid    = "DenyRegions"
    effect = "Deny"
    not_actions = [
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
      values   = var.allowed_regions
    }
  }
}

resource "aws_organizations_policy" "region_denial" {
  name        = "SCP-Region-Denial"
  description = "Denies the creation of resources outside allowed regions."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_denial.json
}

# Attach SCP to Workloads OU
resource "aws_organizations_policy_attachment" "region_denial_workloads" {
  policy_id = aws_organizations_policy.region_denial.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

# SCP: Require 'Custo' tag on specific resource creation for cost allocation

data "aws_iam_policy_document" "mandatory_tags" {
  statement {
    sid    = "EnforceCostTag"
    effect = "Deny"
    actions = [
      "ec2:RunInstances",
      "s3:CreateBucket",
      "rds:CreateDBInstance",
      "lambda:CreateFunction"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/Custo"
      values   = ["true"]
    }
  }
}

resource "aws_organizations_policy" "mandatory_tags" {
  name        = "SCP-Mandatory-Tags"
  description = "Mandates the inclusion of the 'Custo' tag when creating selected resources."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.mandatory_tags.json
}

# Attach tagging SCP to Workloads OU
resource "aws_organizations_policy_attachment" "mandatory_tags_workloads" {
  policy_id = aws_organizations_policy.mandatory_tags.id
  target_id = aws_organizations_organizational_unit.workloads.id
}
