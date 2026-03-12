# IAM Identity Center (SSO) Data Source

data "aws_ssoadmin_instances" "sso_instance" {}


# Admin Permission Set
resource "aws_ssoadmin_permission_set" "admin_access" {
  name             = "AdministratorAccess"
  description      = "Full access to AWS services."
  instance_arn     = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin_access_policy" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Read-Only Permission Set
resource "aws_ssoadmin_permission_set" "read_only_access" {
  name             = "ReadOnlyAccess"
  description      = "Read-only access for auditing purposes."
  instance_arn     = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "read_only_access_policy" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.read_only_access.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# SSO Assignments (Per-Account)
# Target types are AWS_ACCOUNT. Map User/Group IDs to proper target_ids.

# Example assignments (uncomment/adjust principal_id):
# resource "aws_ssoadmin_account_assignment" "dev_admin" {
#   instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
#   permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
#   target_type        = "AWS_ACCOUNT"
#   target_id          = aws_organizations_account.dev_security.id
#   principal_type     = "GROUP"
#   principal_id       = "YOUR-GROUP-ID-HERE"
# }

# resource "aws_ssoadmin_account_assignment" "audit_readonly" {
#   instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
#   permission_set_arn = aws_ssoadmin_permission_set.read_only_access.arn
#   target_type        = "AWS_ACCOUNT"
#   target_id          = aws_organizations_account.audit.id
#   principal_type     = "GROUP"
#   principal_id       = "YOUR-AUDIT-GROUP-ID-HERE"
# }
