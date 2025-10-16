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
    git clone <URL_DO_REPOSITÓRIO>
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