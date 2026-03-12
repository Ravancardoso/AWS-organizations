# AWS Organizations - Estrutura Central com Terraform

Este repositório contém a **configuração central do Terraform** para a gestão do nosso **ambiente AWS multi-contas**. Seu objetivo principal é definir a estrutura fundamental de governança, segurança e faturamento da empresa na nuvem, atuando como a nossa **Landing Zone Core**.

### **O que este repositório provisiona:**

* **AWS Organization:** Criação e gerenciamento do recurso `aws_organizations_organization` (Habilitado com `Feature Set: ALL`).
* **Unidades Organizacionais (OUs):** Definição da hierarquia completa das OUs (ex: **`Infrastructure`**, **`Workloads`**, **`Security`**).
* **Contas Membro Fundamentais:** Provisionamento de contas essenciais (ex: **`Audit`**, **`Log Archive`**) alocadas nas OUs apropriadas.
* **Governança:** Anexação de **Service Control Policies (SCPs)** de nível raiz/OU para aplicar limites de permissão e garantir a conformidade básica de segurança.

---

## 🚀 Pré-requisitos

Para utilizar este módulo, certifique-se de ter o seguinte configurado localmente:

1.  **Terraform CLI:** Versão `>= 1.2.0`.
2.  **AWS CLI:** Para configuração de credenciais e validação.
3.  **Acesso à Conta de Gerenciamento (Management Account):** As credenciais AWS devem ser configuradas para a **Conta Raiz/Gerenciamento** da Organização.
4.  **Backend Remoto:** Um bucket S3 (e tabela DynamoDB para State Locking) configurado para armazenar o `terraform.tfstate`.
    * **Importante:** Nunca execute este código com um state local. O `state` deve ser seguro e centralizado.

---

## 🛠️ Como Usar (Workflow)

Siga os passos abaixo na sua máquina local, garantindo que você esteja autenticado na AWS com as permissões corretas (Management Account):

1.  **Clonar o Repositório:**
    ```bash
    git clone https://github.com/Ravancardoso/AWS-organizations.git
    cd terraform-aws-organizations
    ```

2.  **Inicializar:** Baixa os provedores e configura o backend remoto.
    ```bash
    terraform init
    ```

3.  **Planejar:** Analisa as mudanças propostas sem executá-las.
    ```bash
    terraform plan
    ```

4.  **Aplicar:** Executa as mudanças e provisiona a infraestrutura na AWS.
    ```bash
    terraform apply
    ```

---

## 📂 Estrutura do Projeto

O código está organizado da seguinte forma:

| Arquivo/Diretório | Objetivo |
| :--- | :--- |
| `versions.tf` | Define o provedor AWS e a versão mínima do Terraform. |
| `organization.tf` | Cria o recurso central da Organization e integrações de serviço (SSO, CloudTrail). |
| `ous.tf` | Define a hierarquia e os nomes de todas as Unidades Organizacionais. |
| `accounts.tf` | Provisiona novas Contas Membro (ex: Log Archive, Audit). |
| `policies/` | Diretório contendo os arquivos JSON para as Service Control Policies (SCPs). |
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.conta_master](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/budgets_budget) | resource |
| [aws_budgets_budget.sandbox](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/budgets_budget) | resource |
| [aws_cloudtrail.organization_trail](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.budgets_execution_role](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/iam_role) | resource |
| [aws_iam_role.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.log_encryption_alias](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.log_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/kms_key) | resource |
| [aws_organizations_account.audit](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_account) | resource |
| [aws_organizations_account.dev_security](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_account) | resource |
| [aws_organizations_account.hml_security](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_account) | resource |
| [aws_organizations_account.log_archive](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_account) | resource |
| [aws_organizations_account.prod_security](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.main](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.sandbox](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.security](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.workloads](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_policy.mandatory_tags](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.region_denial](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.mandatory_tags_workloads](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.region_denial_workloads](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/organizations_policy_attachment) | resource |
| [aws_s3_bucket.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudtrail_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/s3_bucket_versioning) | resource |
| [aws_ssoadmin_managed_policy_attachment.admin_access_policy](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.read_only_access_policy](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.admin_access](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set.read_only_access](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/resources/ssoadmin_permission_set) | resource |
| [aws_iam_policy_document.cloudtrail_assume_role](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_put_logs](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_s3_access](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mandatory_tags](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.region_denial](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/organizations_organization) | data source |
| [aws_ssoadmin_instances.sso_instance](https://registry.terraform.io/providers/hashicorp/aws/4.60.0/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_regions"></a> [allowed\_regions](#input\_allowed\_regions) | Allowed AWS regions for resource provisioning (used in SCPs). | `list(string)` | <pre>[<br/>  "us-east-1"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Primary region. MUST be us-east-1 for Org and SSO resources. | `string` | `"us-east-1"` | no |
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | Base domain for member account emails. | `string` | `"seu-dominio.com"` | no |
| <a name="input_billing_contacts"></a> [billing\_contacts](#input\_billing\_contacts) | Emails for budget notifications. | `list(string)` | <pre>[<br/>  "financeiro@suaempresa.com",<br/>  "infra-team@suaempresa.com"<br/>]</pre> | no |
| <a name="input_master_account_email"></a> [master\_account\_email](#input\_master\_account\_email) | Management Account email (immutable). | `string` | n/a | yes |
| <a name="input_org_prefix"></a> [org\_prefix](#input\_org\_prefix) | Prefix for account names. | `string` | `"MinhaEmpresa"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization and account name identifier. | `string` | `"MinhaEmpresa-Org"` | no |
| <a name="input_sandbox_budget_limit"></a> [sandbox\_budget\_limit](#input\_sandbox\_budget\_limit) | Monthly spend limit (USD) for Sandbox OU. | `number` | `100` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default resource tags. | `map(string)` | <pre>{<br/>  "Ambiente": "Security",<br/>  "Custo": "100.00",<br/>  "Proprietario": "Ravan Cardoso"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_bucket_arn"></a> [cloudtrail\_bucket\_arn](#output\_cloudtrail\_bucket\_arn) | ARN of the centralized S3 bucket for CloudTrail logs. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | Main AWS Organization ID. |
| <a name="output_security_ou_id"></a> [security\_ou\_id](#output\_security\_ou\_id) | Security Organizational Unit ID. |
<!-- END_TF_DOCS -->