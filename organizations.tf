# ------------------------------------------------------------------
# 1. RECURSO PRINCIPAL: AWS ORGANIZATION
# ------------------------------------------------------------------

# Cria ou gerencia o AWS Organization.
# Se a organização já existe, o Terraform tentará 'adotar' o estado dela.
resource "aws_organizations_organization" "main" {
  # Habilita o acesso de serviços confiáveis (Trusted Access)
  # Estes são essenciais para governança e segurança centralizadas.
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",    # Para CloudTrail centralizado
    "config.amazonaws.com",      # Para AWS Config centralizado
    "ssm.amazonaws.com",         # Para Gerenciamento de Sistemas (SSM)
    "securityhub.amazonaws.com", # Para Security Hub
    "fms.amazonaws.com",         # Para Firewall Manager
    "sso.amazonaws.com",         # Para AWS Single Sign-On (SSO) / IAM Identity Center
  ]
  
  # Habilita todos os recursos (Controle de Políticas de Serviços - SCPs)
  feature_set = "ALL"
}

# ------------------------------------------------------------------
# 2. UNIDADES ORGANIZACIONAIS (OUs) DE ALTO NÍVEL
# ------------------------------------------------------------------

# Obtém o ID da raiz da Organization (necessário para anexar OUs)
data "aws_organizations_organization" "current" {}

# OU para Contas de Segurança e Logs (Regras de acesso muito restritas)
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# OU para Contas de Workloads (Desenvolvimento, Staging, Produção)
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# OU para Contas Sandbox/Experimentação (Permissões mais flexíveis, mas com limites de custo)
resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# ------------------------------------------------------------------
# 3. CONTAS ESSENCIAIS DE GOVERNANÇA (DENTRO DA OU 'Security')
# ------------------------------------------------------------------

# 3.1. Conta de Logs Centralizados
# Todos os logs (CloudTrail, VPC Flow Logs, etc.) de todas as contas irão para cá.
resource "aws_organizations_account" "log_archive" {
  name      = "${var.organization_name}-LogArchive"
  email     = "log-archive+${var.organization_name}@dominio.com" # SUBSTITUA pelo seu e-mail
  parent_id = aws_organizations_organizational_unit.security.id
  role_name = "OrganizationAccountAccessRole" # Role para acesso do Master Account
}

# 3.2. Conta de Auditoria e Acesso Restrito
# Usada por times de segurança para auditoria e acesso a logs.
resource "aws_organizations_account" "audit" {
  name      = "${var.organization_name}-Audit"
  email     = "audit+${var.organization_name}@dominio.com" # SUBSTITUA pelo seu e-mail
  parent_id = aws_organizations_organizational_unit.security.id
  role_name = "OrganizationAccountAccessRole"
}

# ------------------------------------------------------------------
# 4. CONTAS DE WORKLOADS (DENTRO DA OU 'Workloads')
# ------------------------------------------------------------------

# Exemplo de Contas de Workload (Desenvolvimento)
resource "aws_organizations_account" "development" {
  name      = "${var.organization_name}-Development"
  email     = "dev+${var.organization_name}@dominio.com" # SUBSTITUA pelo seu e-mail
  parent_id = aws_organizations_organizational_unit.workloads.id
  role_name = "OrganizationAccountAccessRole"
}

# ------------------------------------------------------------------
# 5. OUTPUTS (Valores úteis para outros módulos)
# ------------------------------------------------------------------

output "organization_id" {
  description = "ID da AWS Organization principal."
  value       = aws_organizations_organization.main.id
}

output "security_ou_id" {
  description = "ID da Unidade Organizacional de Segurança."
  value       = aws_organizations_organizational_unit.security.id
}