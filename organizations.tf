# AWS Organization core resource
resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ssm.amazonaws.com",
    "securityhub.amazonaws.com",
    "fms.amazonaws.com",
    "sso.amazonaws.com",
  ]

  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]
}

# Organization Root lookup
locals {
  root_id = aws_organizations_organization.main.roots[0].id
}

# ------------------------------------------------------------------
# OUs
# ------------------------------------------------------------------

# Management Account OU
resource "aws_organizations_organizational_unit" "management" {
  name      = "Management"
  parent_id = local.root_id

  depends_on = [aws_organizations_organization.main]
}

# Security and Log Archive OU
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = local.root_id

  depends_on = [aws_organizations_organization.main]
}

# Workloads OU (Dev/Stg/Prod)
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = local.root_id

  depends_on = [aws_organizations_organization.main]
}

# Sandbox/Experimentation OU
resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = local.root_id

  depends_on = [aws_organizations_organization.main]
}

# ------------------------------------------------------------------
# MANAGEMENT ACCOUNT (Imported only)
# ------------------------------------------------------------------

# Reference to the existing Management Account (ID: 377494600646)
# NOT managed by Terraform; must be imported statefully:
# terraform import aws_organizations_account.management 377494600646
resource "aws_organizations_account" "management" {
  name      = "Conta-Master"
  email     = "seu-email-root@seu-dominio.com" # Original account email
  parent_id = aws_organizations_organizational_unit.management.id
  role_name = "OrganizationAccountAccessRole"

  lifecycle {
    prevent_destroy = true
    # Ignore state changes for manually provisioned management account
    ignore_changes = [email, name, role_name]
  }
}

# ------------------------------------------------------------------
# SECURITY ACCOUNTS
# ------------------------------------------------------------------

# Centralized Log Archive Account
resource "aws_organizations_account" "log_archive" {
  name      = "${var.org_prefix}-LogArchive"
  email     = "log-archive+${var.org_prefix}@${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.security.id
  role_name = "OrganizationAccountAccessRole"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [email, name]
  }
}

# Audit/Security Tooling Account
resource "aws_organizations_account" "audit" {
  name      = "${var.org_prefix}-Audit"
  email     = "audit+${var.org_prefix}@${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.security.id
  role_name = "OrganizationAccountAccessRole"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [email, name]
  }
}

# ------------------------------------------------------------------
# WORKLOAD ACCOUNTS
# ------------------------------------------------------------------

# Development Account
resource "aws_organizations_account" "dev_security" {
  name      = "${var.org_prefix}-Dev-Security"
  email     = "security@dev.${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = "OrganizationAccountAccessRole"

  tags = merge(local.default_tags, local.environment_tags, {
    Ambiente = "Development"
  })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [email, name]
  }
}

# Staging/Homologation Account
resource "aws_organizations_account" "hml_security" {
  name      = "${var.org_prefix}-HML-Security"
  email     = "security@hml.${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = "OrganizationAccountAccessRole"

  tags = merge(local.default_tags, local.environment_tags, {
    Ambiente = "Homologation"
  })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [email, name]
  }
}

# Production Account
resource "aws_organizations_account" "prod_security" {
  name      = "${var.org_prefix}-Prod-Security"
  email     = "security@prod.${var.base_domain}"
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = "OrganizationAccountAccessRole"

  tags = merge(local.default_tags, local.environment_tags, {
    Ambiente = "Production"
  })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [email, name]
  }
}
