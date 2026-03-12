# AWS Organization core resource
resource "aws_organizations_organization" "main" {
  # Trusted services enabled across the Org
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ssm.amazonaws.com",
    "securityhub.amazonaws.com",
    "fms.amazonaws.com",
    "sso.amazonaws.com",
  ]

  feature_set = "ALL"
}

# Organization Root lookup
data "aws_organizations_organization" "current" {}

# Security and Log Archive OU
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# Workloads OU (Dev/Stg/Prod)
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# Sandbox/Experimentation OU
resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# Centralized Log Archive Account
resource "aws_organizations_account" "log_archive" {
  name      = "${var.org_prefix}-LogArchive"
  email     = "log-archive+${var.org_prefix}@${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.security.id
  role_name = "OrganizationAccountAccessRole"
}

# Audit/Security Tooling Account
resource "aws_organizations_account" "audit" {
  name      = "${var.org_prefix}-Audit"
  email     = "audit+${var.org_prefix}@${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.security.id
  role_name = "OrganizationAccountAccessRole"
}

# Development Account
resource "aws_organizations_account" "dev_security" {
  name      = "${var.org_prefix}-Dev-Security"
  email     = "security@dev.${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = "OrganizationAccountAccessRole"
  tags = {
    Ambiente = "Development"
  }
}

# Staging/Homologation Account
resource "aws_organizations_account" "hml_security" {
  name      = "${var.org_prefix}-HML-Security"
  email     = "security@hml.${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = "OrganizationAccountAccessRole"
  tags = {
    Ambiente = "Homologation"
  }
}

# Production Account
resource "aws_organizations_account" "prod_security" {
  name      = "${var.org_prefix}-Prod-Security"
  email     = "security@prod.${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = "OrganizationAccountAccessRole"
  tags = {
    Ambiente = "Production"
  }
}

# Org Outputs

output "organization_id" {
  description = "Main AWS Organization ID."
  value       = aws_organizations_organization.main.id
}

output "security_ou_id" {
  description = "Security Organizational Unit ID."
  value       = aws_organizations_organizational_unit.security.id
}