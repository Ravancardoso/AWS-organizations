variable "aws_region" {
  description = "Primary region. MUST be us-east-1 for Org and SSO resources."
  type        = string
  default     = "us-east-1"
}

variable "organization_name" {
  description = "Organization and account name identifier."
  type        = string
  default     = "MinhaEmpresa-Org"
}

variable "master_account_email" {
  description = "Management Account email (immutable)."
  type        = string
}

variable "org_prefix" {
  description = "Prefix for account names."
  type        = string
  default     = "MinhaEmpresa"
}

variable "base_domain" {
  description = "Base domain for member account emails."
  type        = string
  default     = "seu-dominio.com"
}

variable "allowed_regions" {
  description = "Allowed AWS regions for resource provisioning (used in SCPs)."
  type        = list(string)
  default     = ["us-east-1"]
}

variable "billing_contacts" {
  description = "Emails for budget notifications."
  type        = list(string)
  default     = ["financeiro@suaempresa.com", "infra-team@suaempresa.com"]
}

variable "sandbox_budget_limit" {
  description = "Monthly spend limit (USD) for Sandbox OU."
  type        = number
  default     = 100.00
}

variable "tags" {
  description = "Default resource tags."
  type        = map(string)
  default = {
    Ambiente     = "Security"
    Proprietario = "Ravan Cardoso"
    Custo        = "100.00"
  }
}
