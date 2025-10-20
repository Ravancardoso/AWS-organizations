# ------------------------------------------------------------------
# 1. HABILITAR O IAM IDENTITY CENTER (SSO)
# ------------------------------------------------------------------

# Isto cria a instância do Identity Center na sua Organization
resource "aws_ssoadmin_instance_access_control_attribute_configuration" "sso_enable" {
  instance_arn = aws_ssoadmin_instances.sso_instance.arns[0]
  # Configuração mínima, apenas para garantir que a instância seja criada
}

# Obtém a instância do SSO que acabou de ser criada (ou que já existe)
data "aws_ssoadmin_instances" "sso_instance" {}


# ------------------------------------------------------------------
# 2. DEFINIR UM PERMISSION SET (Conjunto de Permissões)
# ------------------------------------------------------------------

# Cria um Permission Set de 'Acesso de Administrador'
resource "aws_ssoadmin_permission_set" "admin_access" {
  name             = "AdministratorAccess"
  description      = "Acesso total aos serviços AWS."
  instance_arn     = data.aws_ssoadmin_instances.sso_instance.arns[0]
  session_duration = "PT4H" # Duração da sessão de 4 horas
}

# Anexa a política gerenciada 'AdministratorAccess' ao Permission Set
resource "aws_ssoadmin_permission_set_inline_policy" "admin_access_policy" {
  instance_arn     = data.aws_ssoadmin_instances.sso_instance.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  # Anexa a política gerenciada da AWS
  inline_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
}

# ------------------------------------------------------------------
# 3. ATRIBUIR O PERMISSION SET ÀS CONTAS/OUs
# ------------------------------------------------------------------

# Atribui o Permission Set 'AdministratorAccess' à OU de Workloads.
# Isso significa que qualquer usuário/grupo atribuído a este Permission Set
# terá esse acesso em TODAS as contas sob a OU Workloads.
resource "aws_ssoadmin_account_assignment" "workloads_admin_group" {
  instance_arn       = data.aws_ssoadmin_instances.sso_instance.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  # Tipo de Entidade (GROUP ou USER)
  target_type = "AWS_ORGANIZATIONAL_UNIT"
  target_id   = aws_organizations_organizational_unit.workloads.id # ID da OU 'Workloads'

  # ID da Entidade (Grupo ou Usuário)
  principal_type = "GROUP"
  # O nome ou ID do grupo que você criará no IAM Identity Center ou no seu IdP externo.
  # Você precisará configurar isso manualmente ou usar recursos mais avançados (Identity Store).
  principal_id = "Seu-Grupo-Admin-Criado-Manualmente-ou-Via-SCIM" 
}