
# VARIÁVEIS 


variable "aws_region" {
  description = "Região principal para a Organization. DEVE ser us-east-1 para recursos da Org e SSO."
  type        = string
  default     = "us-east-1"
}

variable "organization_name" {
  description = "Nome para identificar a Organization e suas contas."
  type        = string
  default     = "MinhaEmpresa-Org"
}

variable "master_account_email" {
  description = "E-mail da conta principal (Management Account). NÃO pode ser alterado após a criação."
  type        = string
 
 }

variable "root_ou_name" {
  description = "Nome da Unidade Organizacional (OU) raiz para a maioria das OUs."
  type        = string
  default     = "Root" 
}

variable "tags" {
  description = "Tags padrão para aplicar na maioria dos recursos da AWS."
  type        = map(string)
  default = {
    Ambiente    = "Producao"
    Proprietario = "Infra-Team"
    Custo        = "0000"
  }
}

variable "billing_contacts" {
  description = "Lista de e-mails para receber notificações de orçamento (Budgets)."
  type        = list(string)
  default     = ["financeiro@suaempresa.com", "infra-team@suaempresa.com"]
}

variable "sandbox_budget_limit" {
  description = "Limite máximo de gasto mensal (em USD) para a OU Sandbox."
  type        = number
  default     = 100.00
}