# Azure Data Platform Infrastructure with Terraform

## Overview

This project demonstrates the design, deployment, security, observability, and CI/CD automation of an Azure data platform using Terraform.

The project was built as a hands-on platform engineering exercise aligned to the responsibilities of a **Data Platform Engineer** working with Azure, Terraform, Infrastructure as Code (IaC), CI/CD, cloud security, monitoring, and operational reliability.

The platform was initially built as a single Terraform root configuration and then progressively improved into a more enterprise-style architecture with:

- Azure infrastructure provisioned with Terraform
- Remote Terraform state stored in Azure Storage
- Azure Data Lake Storage Gen2
- Azure Data Factory
- Azure Key Vault
- Azure virtual networking
- Private Endpoints and Private DNS
- Managed identities and Azure RBAC
- Azure Monitor and Log Analytics
- Diagnostic settings and alerting
- GitHub Actions CI/CD
- Azure OIDC authentication
- Terraform linting with TFLint
- IaC security scanning with Trivy
- Reusable Terraform modules
- Separate dev, test, and prod environment roots
- Safe Terraform state refactoring using `moved` blocks

The project was deliberately developed incrementally so that each platform engineering concept could be understood before the next layer was introduced.

---

# Architecture

```text
                               GitHub
                                  |
                         Feature Branch / PR
                                  |
                  +---------------+---------------+
                  |                               |
               TFLint                          Trivy
                  |                               |
                  +---------------+---------------+
                                  |
                         Terraform Validate
                                  |
                         Terraform Plan
                                  |
                         Azure OIDC Login
                                  |
                         Review / Merge
                                  |
                               main
                                  |
                         GitHub Environment
                                  |
                         Terraform Apply
                                  |
                                  v
                              Microsoft Azure
                                  |
                    +-------------+-------------+
                    |                           |
                 Security                    Platform
                    |                           |
                  VNet                      Data Factory
                    |                           |
           Private Endpoints               Managed IR
                    |                           |
              Private DNS              Managed Private
                    |                    Endpoints
          +---------+---------+               |
          |                   |               |
       ADLS Gen2          Key Vault           |
          |                   |               |
          +---------+---------+---------------+
                    |
                 Azure RBAC
                    |
              Managed Identity
                    |
                    v
             Observability Layer
                    |
        +-----------+-----------+
        |                       |
   Log Analytics            Azure Monitor
        |                       |
      KQL                  Metric Alerts
                                |
                          Action Groups
                                |
                              Email
```

---

# Repository Structure

```text
azure-data-platform-iac/
|
|-- bootstrap/
|   |-- versions.tf
|   |-- variables.tf
|   |-- main.tf
|   `-- outputs.tf
|
|-- modules/
|   |
|   |-- networking/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   |
|   |-- storage/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   |
|   |-- keyvault/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   |
|   |-- datafactory/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   |
|   `-- monitoring/
|       |-- main.tf
|       |-- variables.tf
|       `-- outputs.tf
|
|-- environments/
|   |
|   |-- dev/
|   |   |-- versions.tf
|   |   |-- backend.hcl
|   |   |-- variables.tf
|   |   |-- terraform.tfvars
|   |   |-- locals.tf
|   |   |-- resource_group.tf
|   |   |-- main.tf
|   |   |-- rbac.tf
|   |   |-- moved.tf
|   |   `-- outputs.tf
|   |
|   |-- test/
|   |
|   `-- prod/
|
|-- .github/
|   `-- workflows/
|       |-- terraform-pr.yml
|       `-- terraform-deploy.yml
|
|-- .tflint.hcl
|-- .gitignore
`-- README.md
```

---

# Technology Stack

## Infrastructure as Code

- Terraform
- HashiCorp AzureRM Provider
- HCL
- Terraform remote state
- Terraform modules
- Terraform `moved` blocks

## Azure

- Azure Resource Groups
- Azure Virtual Network
- Azure Subnets
- Azure Private Endpoints
- Azure Private DNS
- Azure Data Lake Storage Gen2
- Azure Data Factory
- Azure Managed Virtual Network
- Azure Integration Runtime
- Azure Data Factory Managed Private Endpoints
- Azure Key Vault
- Microsoft Entra ID
- Azure Managed Identity
- Azure RBAC
- Azure Log Analytics
- Azure Monitor
- Azure Monitor Diagnostic Settings
- Azure Monitor Metric Alerts
- Azure Monitor Action Groups

## DevOps / CI/CD

- Git
- GitHub
- GitHub Actions
- GitHub Environments
- Azure OIDC / Workload Identity Federation
- Pull Request workflows

## Code Quality / Security

- TFLint
- AzureRM TFLint rules
- Trivy IaC scanning
- Terraform validation
- Terraform format checking

## Operations / Observability

- Log Analytics
- Azure Monitor
- Kusto Query Language (KQL)
- Diagnostic logs
- Metrics
- Alerting
- Email notifications

---

# 1. Terraform Bootstrap Layer

The first stage of the project was to create the infrastructure required to store Terraform state remotely.

Terraform state contains the relationship between Terraform configuration and deployed cloud resources.

Instead of keeping the platform state only on a developer laptop, an Azure Storage Account was created specifically for Terraform state.

## Bootstrap Architecture

```text
Azure Subscription
       |
       v
rg-tfstate-dev
       |
       v
Azure Storage Account
       |
       v
tfstate container
       |
       v
data-platform/dev.tfstate
```

## Why Remote State?

Remote state provides:

- Shared state for engineers and CI/CD
- A consistent source of truth
- Better collaboration
- Reduced risk of local state loss
- State locking support
- Centralised access control
- CI/CD integration

Example backend:

```hcl
terraform {
  backend "azurerm" {}
}
```

Backend configuration:

```hcl
container_name = "tfstate"
key            = "data-platform/dev.tfstate"
```

Authentication details are supplied at runtime rather than stored directly in the backend file.

---

# 2. Initial Azure Platform Build

The first version of the platform was created as a single Terraform root module.

The platform included:

- Resource Group
- Virtual Network
- Integration subnet
- Private Endpoint subnet
- ADLS Gen2
- Landing container
- Raw container
- Curated container
- Azure Key Vault
- Azure Data Factory
- Data Factory managed identity
- Azure RBAC
- Log Analytics

---

# 3. Azure Networking

A dedicated VNet was created for the data platform.

Example:

```text
vnet-data-platform-dev
10.20.0.0/16
|
|-- snet-integration
|   10.20.1.0/24
|
`-- snet-private-endpoints
    10.20.2.0/24
```

Terraform example:

```hcl
resource "azurerm_virtual_network" "platform" {
  name                = "vnet-data-platform-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = var.vnet_address_space

  tags = var.tags
}
```

The dedicated subnet for private endpoints separates private connectivity from general integration workloads.

---

# 4. Azure Data Lake Storage Gen2

The platform uses an Azure StorageV2 account configured with Hierarchical Namespace.

```hcl
is_hns_enabled = true
```

This enables Azure Data Lake Storage Gen2 capabilities.

The logical lake layers are:

```text
ADLS Gen2
|
|-- landing
|
|-- raw
|
`-- curated
```

Conceptually:

```text
Source Systems
      |
      v
   Landing
      |
      v
     Raw
      |
      v
Transformation
      |
      v
   Curated
      |
      v
Analytics / BI
```

Security controls include:

```hcl
min_tls_version                 = "TLS1_2"
allow_nested_items_to_be_public = false
public_network_access_enabled   = false
```

---

# 5. Azure Key Vault

Azure Key Vault is used as the platform secrets-management service.

The platform uses Azure RBAC rather than legacy Key Vault access policies.

```hcl
rbac_authorization_enabled = true
```

The design avoids hard-coded secrets in Terraform configuration.

Conceptually:

```text
ADF
 |
Managed Identity
 |
 v
Key Vault
 |
 v
Secrets
```

Public network access was disabled after private connectivity was implemented.

---

# 6. Azure Data Factory

Azure Data Factory was deployed with a system-assigned managed identity.

```hcl
identity {
  type = "SystemAssigned"
}
```

This gives ADF its own identity in Microsoft Entra ID.

Instead of using storage keys or passwords:

```text
ADF
 |
Managed Identity
 |
Azure RBAC
 |
ADLS
```

The Data Factory identity was granted:

```text
Storage Blob Data Contributor
```

on the Data Lake.

It was also granted:

```text
Key Vault Secrets User
```

on Azure Key Vault.

This follows the principle of least privilege.

---

# 7. Azure RBAC

RBAC was used to answer three questions:

```text
WHO?
 |
 v
Principal / Managed Identity

WHAT?
 |
 v
Role

WHERE?
 |
 v
Azure Resource Scope
```

Example:

```hcl
resource "azurerm_role_assignment" "adf_storage_data_contributor" {
  scope = module.storage.datalake_id

  role_definition_name = "Storage Blob Data Contributor"

  principal_id = module.datafactory.principal_id

  principal_type = "ServicePrincipal"
}
```

This means:

```text
WHO:
ADF Managed Identity

WHAT:
Storage Blob Data Contributor

WHERE:
ADLS Storage Account
```

---

# 8. Security Upgrade - Private Link

The next major upgrade was private networking.

Private Endpoints were created for:

- ADLS Blob
- ADLS DFS
- Azure Key Vault

## Why Blob and DFS?

ADLS Gen2 uses both Blob and DFS endpoints.

```text
ADLS Gen2
   /   \
  /     \
Blob    DFS
 PE      PE
```

Both were configured to avoid incomplete private connectivity.

---

# 9. Azure Private DNS

Private DNS zones were created for:

```text
privatelink.blob.core.windows.net
privatelink.dfs.core.windows.net
privatelink.vaultcore.azure.net
```

Each zone was linked to the platform VNet.

Conceptually:

```text
VNet
 |
 |-- privatelink.blob.core.windows.net
 |
 |-- privatelink.dfs.core.windows.net
 |
 `-- privatelink.vaultcore.azure.net
```

This enables Azure resources inside the VNet to resolve service names to private IP addresses.

---

# 10. Data Factory Managed Virtual Network

ADF private networking is different from normal VNet Private Endpoints.

ADF uses a service-managed network:

```text
Azure Data Factory
       |
       v
ADF Managed Virtual Network
       |
       v
Managed Azure Integration Runtime
```

The Data Factory was configured with:

```hcl
managed_virtual_network_enabled = true
```

A Managed Azure Integration Runtime was created with:

```hcl
virtual_network_enabled = true
```

---

# 11. ADF Managed Private Endpoints

ADF Managed Private Endpoints were created for:

- Storage Blob
- Storage DFS
- Key Vault

Architecture:

```text
ADF
 |
Managed Virtual Network
 |
Managed Integration Runtime
 |
+-------------------+
|                   |
v                   v
ADLS              Key Vault
```

Private endpoint connection requests were approved on the destination resources.

---

# 12. Public Access Lockdown

Private connectivity was established before disabling public network access.

After validation:

```hcl
public_network_access_enabled = false
```

was applied to:

- ADLS
- Azure Key Vault

This follows a safer migration strategy:

```text
Create Private Connectivity
        |
        v
Validate Connectivity
        |
        v
Disable Public Network Access
```

---

# 13. Observability

The platform includes a central observability layer.

```text
ADF -----------+
               |
ADLS ----------+--> Diagnostic Settings
               |          |
Key Vault -----+          v
                    Log Analytics
                         |
                         v
                        KQL
```

---

# 14. Log Analytics

A central Log Analytics workspace was created:

```text
law-data-platform-dev
```

This acts as the central store for operational and audit logs.

---

# 15. Data Factory Diagnostics

ADF diagnostic settings collect:

```text
PipelineRuns
ActivityRuns
TriggerRuns
```

Resource-specific logging was enabled where appropriate.

Typical Log Analytics tables include:

```text
ADFPipelineRun
ADFActivityRun
ADFTriggerRun
```

Example KQL:

```kusto
ADFPipelineRun
| where TimeGenerated > ago(24h)
| where Status == "Failed"
| project
    TimeGenerated,
    PipelineName,
    FailureType,
    ErrorCode,
    ErrorMessage,
    RunId
| order by TimeGenerated desc
```

---

# 16. ADLS Diagnostics

Storage Blob diagnostic categories include:

```text
StorageRead
StorageWrite
StorageDelete
```

These are written to:

```text
StorageBlobLogs
```

Example query:

```kusto
StorageBlobLogs
| where TimeGenerated > ago(24h)
| project
    TimeGenerated,
    OperationName,
    AuthenticationType,
    StatusCode,
    StatusText,
    CallerIpAddress,
    Uri
| order by TimeGenerated desc
```

Security validation example:

```kusto
StorageBlobLogs
| where TimeGenerated > ago(7d)
| where AuthenticationType == "Anonymous"
```

---

# 17. Key Vault Diagnostics

Key Vault audit logging was enabled using:

```text
AuditEvent
```

This supports investigations into:

- Vault access
- Authentication
- RBAC authorisation
- Network authorisation
- Failed access
- Successful access

---

# 18. Metrics and Alerts

Logs and metrics serve different purposes.

## Logs

Used for:

- Troubleshooting
- Root-cause analysis
- Security investigations
- Auditing

## Metrics

Used for:

- Health signals
- Thresholds
- Alerting
- Dashboards

A Data Factory metric alert was created for:

```text
PipelineFailedRuns
```

Condition:

```text
PipelineFailedRuns > 0
```

---

# 19. Azure Monitor Action Group

An Action Group was created to notify operators when an alert fires.

Current notification:

```text
Email
```

Conceptually:

```text
ADF Pipeline Failure
        |
        v
Azure Monitor Metric
        |
        v
Alert Rule
        |
        v
Action Group
        |
        v
Email Notification
```

---

# 20. CI/CD with GitHub Actions

The project was upgraded from local Terraform execution to GitHub Actions CI/CD.

Before:

```text
Developer
 |
PowerShell
 |
az login
 |
Terraform
 |
Azure
```

After:

```text
Developer
 |
Feature Branch
 |
Pull Request
 |
GitHub Actions
 |
Azure OIDC
 |
Terraform
 |
Azure
```

---

# 21. Azure OIDC Authentication

GitHub Actions authenticates to Azure using OpenID Connect / Workload Identity Federation.

No long-lived Azure client secret is required.

There is deliberately no:

```text
AZURE_CLIENT_SECRET
```

The trust model is:

```text
GitHub Actions
      |
      v
OIDC Token
      |
      v
Microsoft Entra ID
      |
      v
Azure Service Principal
      |
      v
Azure
```

This reduces the risk associated with storing long-lived deployment credentials.

---

# 22. Separate Plan and Apply Identities

Two Azure identities were introduced:

```text
gha-azure-data-platform-plan

gha-azure-data-platform-apply
```

## Plan Identity

Used by Pull Request workflows.

Designed primarily for:

```text
terraform plan
```

It receives read-oriented permissions to the deployed platform plus access to the Terraform state container.

## Apply Identity

Used by the deployment workflow.

Designed for:

```text
terraform apply
```

It receives the permissions required to modify the platform.

Because the Terraform project also creates Azure role assignments, the apply identity additionally requires RBAC-management capability at the required scope.

This implements a stronger least-privilege model than using one highly privileged CI identity.

## CI/CD RBAC Model Used

The working CI/CD design ultimately required the following separation of permissions:

| Identity | Purpose | Key Azure permissions |
|---|---|---|
| `gha-azure-data-platform-plan` | Pull Request `terraform plan` | `Reader` on the platform resource group plus `Storage Blob Data Contributor` on the Terraform state container |
| `gha-azure-data-platform-apply` | Post-merge `terraform apply` | `Contributor` on the platform resource group, monitoring permissions required for Azure Monitor diagnostic settings, RBAC-management permission for Terraform-managed role assignments, plus `Storage Blob Data Contributor` on the Terraform state container |

A key lesson from implementation was that **successful OIDC authentication does not automatically mean the identity has sufficient Azure RBAC permissions**.

The plan workflow initially failed with:

```text
Microsoft.Resources/subscriptions/resourceGroups/read
```

because the plan identity did not have sufficient read access at the resource-group scope.

The apply workflow later failed with:

```text
Microsoft.Insights/diagnosticSettings/write
```

while updating Azure Monitor Diagnostic Settings. This was resolved by verifying the identity and RBAC scope used by the workflow and ensuring the apply identity had the required monitoring permissions.

The project therefore treats these as separate concerns:

```text
OIDC authentication
        |
        v
Who is the GitHub workflow?

        +

Azure RBAC
        |
        v
What is that identity allowed to do?
```

Both must be correct for Terraform CI/CD to succeed.

---

# 23. Terraform State Permissions

GitHub identities require access to the remote state container.

The identities receive:

```text
Storage Blob Data Contributor
```

at the Terraform state container scope.

This allows Terraform to:

- Read state
- Update state
- Lock state
- Coordinate CI/CD deployments

---

# 24. Pull Request Workflow

The PR workflow performs:

```text
Pull Request
     |
     v
Terraform Format Check
     |
     v
TFLint
     |
     v
Trivy IaC Scan
     |
     v
Terraform Init
     |
     v
Terraform Validate
     |
     v
Azure OIDC Login
     |
     v
Terraform Plan
     |
     v
Trivy Plan Scan
```

The static quality/security stage does not need Azure credentials.

This means bad Terraform can be rejected before any cloud access is granted.

---

# 25. Deployment Workflow

After changes are reviewed and merged to `main`:

```text
main
 |
 v
GitHub Environment: dev
 |
 v
Azure OIDC
 |
 v
terraform init
 |
 v
terraform validate
 |
 v
terraform plan -out=tfplan
 |
 v
terraform apply tfplan
```

The deployment applies the exact saved execution plan.

---

# 26. Pipeline Concurrency

Deployment concurrency was added to reduce the risk of two CI/CD deployments racing against the same Terraform state.

Example concept:

```text
Deployment A ----+
                 |
                 +--> Remote State
                 |
Deployment B ----+
```

The GitHub workflow prevents parallel environment deployments while the Azure backend also provides state locking.

---

# 27. TFLint

TFLint was introduced for Terraform code quality.

It checks:

- Terraform language issues
- Provider-specific issues
- Deprecated patterns
- Terraform best practices
- Azure-specific rules

Configuration:

```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
```

Typical command:

```powershell
tflint --init
tflint --recursive --format compact
```

---

# 28. Trivy IaC Security Scanning

Trivy was added to scan Terraform configuration for infrastructure security issues.

It scans:

```text
Terraform source
      |
      v
Security Scan
```

and also:

```text
terraform plan
      |
      v
Resolved Plan
      |
      v
Security Scan
```

This gives two security checkpoints:

1. Source configuration scanning
2. Generated-plan scanning

High and critical issues can fail the GitHub workflow.

---

# 29. Terraform Module Refactor

The original Terraform configuration was built as one root module.

As the platform grew, it was refactored into reusable child modules:

```text
modules/
|
|-- networking
|
|-- storage
|
|-- keyvault
|
|-- datafactory
|
`-- monitoring
```

Each module has:

```text
main.tf
variables.tf
outputs.tf
```

---

# 30. Why Modules?

Modules improve:

- Reusability
- Consistency
- Maintainability
- Separation of concerns
- Environment reuse
- Testing
- Code readability

Instead of duplicating infrastructure:

```text
dev/network.tf
test/network.tf
prod/network.tf
```

the project now uses:

```text
             networking module
                   ^
                   |
        +----------+----------+
        |          |          |
       dev        test       prod
```

---

# 31. Module Inputs and Outputs

Modules communicate through inputs and outputs.

Example:

The Networking module creates a private endpoint subnet.

It outputs:

```hcl
output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}
```

The Storage module receives it:

```hcl
private_endpoint_subnet_id =
  module.networking.private_endpoint_subnet_id
```

Conceptually:

```text
Networking Module
       |
creates subnet
       |
outputs subnet ID
       |
       v
Environment Root
       |
passes value
       |
       v
Storage Module
       |
creates private endpoint
```

This is an example of a cross-module dependency.

Terraform automatically infers the dependency from the reference.

---

# 32. Root Environment Composition

The `environments/dev/main.tf` file acts as the composition layer.

It connects:

```text
Networking
    |
    +------> Storage
    |
    +------> Key Vault

Storage ------+
              |
              v
         Data Factory
              ^
              |
Key Vault ----+

Storage ------+
Key Vault ----+----> Monitoring
ADF ----------+
```

The root environment is effectively the conductor coordinating the child modules.

---

# 33. Cross-Service RBAC

Cross-service RBAC remains in the environment root.

For example:

```text
ADF Module
    |
    +---- RBAC ----> Storage Module
    |
    `---- RBAC ----> Key Vault Module
```

This keeps the individual modules focused while allowing the root module to manage relationships between independent platform capabilities.

---

# 34. Safe Terraform State Refactoring

One of the most important parts of the project was refactoring existing deployed resources into modules without destroying them.

Terraform resource addresses changed from:

```text
azurerm_storage_account.datalake
```

to:

```text
module.storage.azurerm_storage_account.datalake
```

Terraform `moved` blocks were used to tell Terraform that the object itself had not changed.

Example:

```hcl
moved {
  from = azurerm_storage_account.datalake
  to   = module.storage.azurerm_storage_account.datalake
}
```

This prevented Terraform from interpreting the refactor as:

```text
Destroy old storage account
Create new storage account
```

Instead:

```text
Existing Azure Resource
       |
Old Terraform Address
       |
       v
Moved State Address
       |
       v
New Module Address
```

---

# 35. State Safety

Before the module migration, Terraform state was backed up.

Example:

```powershell
terraform state pull | Out-File "..\state-backup-before-modules.json" -Encoding utf8
```

A state address list was also saved:

```powershell
terraform state list | Out-File "..\state-list-before-modules.txt" -Encoding utf8
```

The critical safety rule was:

> Never apply a refactor plan that unexpectedly shows mass resource destruction and recreation.

A safe module refactor should show address moves rather than replacement of existing infrastructure.

---

# 36. Environment Separation

The new design supports:

```text
environments/
|
|-- dev/
|
|-- test/
|
`-- prod/
```

Each environment uses the same reusable modules but supplies different configuration.

Example network ranges:

| Environment | VNet |
|---|---|
| Dev | `10.20.0.0/16` |
| Test | `10.30.0.0/16` |
| Prod | `10.40.0.0/16` |

---

# 37. Separate Remote State

Each environment uses its own Terraform state file.

```text
DEV
data-platform/dev.tfstate

TEST
data-platform/test.tfstate

PROD
data-platform/prod.tfstate
```

This reduces the risk of one environment unintentionally managing resources belonging to another.

---

# 38. Development Environment

Example:

```hcl
environment = "dev"
location    = "UK South"

vnet_address_space = [
  "10.20.0.0/16"
]

integration_subnet_prefixes = [
  "10.20.1.0/24"
]

private_endpoint_subnet_prefixes = [
  "10.20.2.0/24"
]
```

---

# 39. Test Environment

Example:

```hcl
environment = "test"
location    = "UK South"

vnet_address_space = [
  "10.30.0.0/16"
]

integration_subnet_prefixes = [
  "10.30.1.0/24"
]

private_endpoint_subnet_prefixes = [
  "10.30.2.0/24"
]
```

Test uses:

```text
data-platform/test.tfstate
```

---

# 40. Production Environment

Example:

```hcl
environment = "prod"
location    = "UK South"

vnet_address_space = [
  "10.40.0.0/16"
]

integration_subnet_prefixes = [
  "10.40.1.0/24"
]

private_endpoint_subnet_prefixes = [
  "10.40.2.0/24"
]
```

Production uses:

```text
data-platform/prod.tfstate
```

In a larger enterprise architecture, separate Azure subscriptions could also be used for stronger isolation.

---

# 41. Local Development Workflow

From the environment root:

```powershell
cd environments\dev
```

Authenticate:

```powershell
az login
```

Set subscription:

```powershell
$env:TF_VAR_subscription_id = az account show --query id -o tsv
```

Set alert email:

```powershell
$env:TF_VAR_alert_email = "YOUR_EMAIL_ADDRESS"
```

Set state storage account:

```powershell
$env:TFSTATE_STORAGE_ACCOUNT = terraform -chdir=..\..\bootstrap output -raw storage_account_name
```

Initialise:

```powershell
terraform init -reconfigure `
  -backend-config="backend.hcl" `
  -backend-config="storage_account_name=$env:TFSTATE_STORAGE_ACCOUNT" `
  -backend-config="use_azuread_auth=true" `
  -backend-config="use_cli=true"
```

Format:

```powershell
terraform fmt -recursive
```

Validate:

```powershell
terraform validate
```

Plan:

```powershell
terraform plan
```

Apply:

```powershell
terraform apply
```

---

# 42. Important Terraform Commands Used

```powershell
terraform init
```

Initialises the Terraform working directory.

```powershell
terraform fmt
```

Formats Terraform configuration.

```powershell
terraform validate
```

Validates Terraform configuration.

```powershell
terraform plan
```

Shows intended changes.

```powershell
terraform apply
```

Applies intended changes.

```powershell
terraform state list
```

Lists resources currently tracked in state.

```powershell
terraform state show <resource>
```

Shows detailed state information for a resource.

```powershell
terraform output
```

Displays output values.

```powershell
terraform state pull
```

Retrieves the current state for backup or inspection.

---

# 43. Git Workflow

Infrastructure changes are developed using branches.

Example:

```powershell
git checkout -b feature/example-change
```

Review changes:

```powershell
git status
```

Stage:

```powershell
git add .
```

Commit:

```powershell
git commit -m "feat: describe infrastructure change"
```

Push:

```powershell
git push -u origin feature/example-change
```

Then create a Pull Request into:

```text
main
```

The CI workflow validates the change before merge.

---

# 44. Branch and Deployment Strategy

```text
feature branch
      |
      v
Pull Request
      |
      v
TFLint
Trivy
Terraform Validate
Terraform Plan
      |
      v
Review
      |
      v
Merge to main
      |
      v
GitHub Environment
      |
      v
OIDC
      |
      v
Terraform Apply
```

---

# 45. `.gitignore`

Terraform state, plan files and local secrets should not be committed.

Example:

```gitignore
.terraform/

*.tfstate
*.tfstate.*

*.tfplan
tfplan

*.tfvars.json

.env
.env.*

crash.log
crash.*.log

override.tf
override.tf.json
*_override.tf
*_override.tf.json

state-backup*.json
state-list*.txt
```

The Terraform dependency lock file should normally remain committed:

```text
.terraform.lock.hcl
```

## Important: Environment `terraform.tfvars`

The environment files used by this project contain **non-secret configuration** such as:

```text
environment
location
VNet CIDR ranges
subnet CIDR ranges
```

For example:

```text
environments/dev/terraform.tfvars
```

These files should be committed if the CI/CD workflow relies on them.

Do not use a blanket `.gitignore` rule such as:

```gitignore
*.tfvars
```

if it would accidentally exclude the tracked environment configuration.

Sensitive values such as the alert email are supplied separately through GitHub Secrets or `TF_VAR_...` environment variables instead of being stored in committed tfvars files.

A CI troubleshooting lesson from this project was that a Terraform plan can fail with missing input-variable errors when the workflow is running from the wrong directory or when required non-secret environment configuration was never committed.

The workflow therefore runs Terraform from:

```text
environments/dev
```

so Terraform automatically loads:

```text
terraform.tfvars
```

from the correct environment root.

---

# 46. Security Principles Demonstrated

The project demonstrates several cloud-security principles:

## Least Privilege

Only required Azure roles are granted.

## Secretless CI/CD

GitHub Actions authenticates using OIDC rather than a long-lived client secret.

## Managed Identity

ADF authenticates to Azure services using its system-assigned identity.

## Private Connectivity

ADLS and Key Vault use Private Endpoints.

## Private DNS

Private Link DNS resolution is handled through Azure Private DNS.

## Public Access Reduction

Public access is disabled after private connectivity is established.

## Security Scanning

Trivy scans Terraform source and generated plans.

## Code Quality

TFLint checks Terraform and Azure-specific configuration quality.

## Auditability

Key Vault and Storage access logs are sent to Log Analytics.

---

# 47. Reliability Principles Demonstrated

The project also includes:

- Terraform remote state
- State locking
- CI/CD concurrency controls
- Saved execution plans
- Pull Request review
- Environment separation
- Monitoring
- Alerting
- Structured module boundaries
- Repeatable deployments

---

# 48. Operational Troubleshooting Model

The project supports troubleshooting from high-level symptom to root cause.

Example:

```text
ADF Pipeline Failed
       |
       v
Azure Monitor Alert
       |
       v
PipelineFailedRuns > 0
       |
       v
ADFPipelineRun
       |
       v
ADFActivityRun
       |
       v
StorageBlobLogs / Key Vault Audit Logs
       |
       v
Root Cause
```

Example diagnosis:

```text
Pipeline failed
     |
     v
Copy activity failed
     |
     v
ADLS returned 403
     |
     v
RBAC / identity / networking investigation
```

---

# 49. Platform Engineering Concepts Demonstrated

This project demonstrates practical experience with:

- Infrastructure as Code
- Terraform state
- Remote state
- AzureRM
- Terraform providers
- Terraform resources
- Terraform data sources
- Input variables
- Locals
- Outputs
- Child modules
- Root modules
- Cross-module dependencies
- Implicit dependencies
- Terraform resource addresses
- Terraform state migration
- Terraform `moved` blocks
- Azure networking
- Azure Private Link
- Private DNS
- Identity
- RBAC
- Least privilege
- Managed identities
- Observability
- Metrics
- Logs
- KQL
- Alerting
- CI/CD
- GitHub Actions
- OIDC
- Environment promotion
- IaC security scanning
- Platform automation

---

# Real-World Issues Encountered and Resolved

The platform was not built as a perfectly linear tutorial. Several genuine Azure/Terraform failures were encountered and resolved during implementation. These issues became some of the most useful platform-engineering lessons in the project.

## 1. `Microsoft.Insights` Provider Registration

When the observability layer was first deployed, Terraform successfully created some resources but Azure Monitor Diagnostic Settings failed with an error similar to:

```text
409 InvalidAuthenticationToken
The subscription is not registered to use namespace 'Microsoft.Insights'
```

The fix was to explicitly register the Azure resource provider:

```powershell
az provider register `
  --namespace Microsoft.Insights `
  --subscription $env:TF_VAR_subscription_id `
  --wait
```

Registration was verified with:

```powershell
az provider show `
  --namespace Microsoft.Insights `
  --subscription $env:TF_VAR_subscription_id `
  --query registrationState `
  -o tsv
```

Expected result:

```text
Registered
```

An important lesson was that Azure resource-provider registration can also require propagation time even after the provider reports `Registered`.

### What Terraform did during the partial failure

The apply was **partially successful**.

For example, resources such as the Log Analytics workspace or Action Group could be created successfully while Diagnostic Settings failed.

Terraform retained the successful resources in state.

The next plan therefore did **not** attempt to recreate everything. It proposed only the resources that had failed.

Conceptually:

```text
First apply
    |
    +-- Log Analytics -------- SUCCESS
    |
    +-- Action Group --------- SUCCESS
    |
    +-- Diagnostic Setting --- FAILED
    |
    `-- Diagnostic Setting --- FAILED


Second terraform plan
    |
    `-- Retry only failed resources
```

This demonstrated why Terraform state must be inspected after a failed or partially successful apply instead of assuming the whole deployment rolled back.

---

## 2. PR Plan Identity Missing Resource-Group Read Permission

The GitHub Actions Pull Request workflow authenticated successfully with Azure through OIDC, but `terraform plan` failed with a `403 AuthorizationFailed` error involving:

```text
Microsoft.Resources/subscriptions/resourceGroups/read
```

The problem was not OIDC.

Authentication had succeeded.

The problem was **authorization**.

The plan identity:

```text
gha-azure-data-platform-plan
```

needed `Reader` access at the platform resource-group scope.

This led to a useful troubleshooting model:

```text
OIDC succeeded
      |
      v
Identity established
      |
      v
Check Azure RBAC
      |
      v
Check role + scope
```

A successful login is therefore only the first step.

---

## 3. Apply Identity Missing Diagnostic-Settings Permission

The deployment workflow later failed while modifying:

```text
Microsoft.Insights/diagnosticSettings
```

with a `403 AuthorizationFailed` error involving:

```text
Microsoft.Insights/diagnosticSettings/write
```

The apply identity was verified using the Azure CLI and its role assignments were reviewed at the relevant scope.

The final CI/CD model ensures that the apply identity has the permissions required for:

```text
normal Azure resource deployment
+
Azure Monitor / diagnostic settings
+
Terraform-managed RBAC role assignments
+
Terraform remote state
```

This issue reinforced an important principle:

> Azure permissions must be designed around the actual resource operations Terraform performs, not merely around the fact that the workflow is called "apply".

---

## 4. Contributor Does Not Cover Every Terraform Operation

The platform uses Terraform to create Azure role assignments.

A standard `Contributor` role can manage most Azure resources, but it does not grant unrestricted role-assignment management.

The apply identity therefore requires dedicated RBAC-management permission at the appropriate scope for Terraform resources such as:

```hcl
resource "azurerm_role_assignment" "..." {
}
```

This is why the CI/CD identity design includes separate RBAC-management capability rather than simply granting broader `Owner` permissions.

---

## 5. Terraform State Access Is Separate from Platform Access

The CI identities need permissions in two different places:

```text
Platform resource group
        |
        +-- Reader / Contributor / Monitoring / RBAC permissions

Terraform state storage
        |
        `-- Storage Blob Data Contributor
```

An identity can have sufficient permissions to inspect Azure resources and still fail during:

```text
terraform init
terraform plan
terraform apply
```

if it cannot access the remote state container.

This was treated as a separate RBAC concern.

---

## 6. CI Workflow Input Variables and Working Directory

During CI/CD testing, Terraform initially behaved as though required variables were missing.

The important checks were:

```text
Is the workflow running from the correct Terraform root?
Are required environment files committed?
Are secrets passed through TF_VAR_*?
```

After the module refactor, the correct Terraform root became:

```text
environments/dev
```

The workflow therefore uses that directory rather than the old:

```text
platform
```

The non-sensitive environment configuration is loaded from:

```text
environments/dev/terraform.tfvars
```

while sensitive values are supplied separately.

This distinction became especially important after the project was refactored into reusable modules.

---

## 7. `terraform plan` Does Not Change Azure

Another useful CI/CD lesson was understanding the boundary between:

```text
terraform plan
```

and:

```text
terraform apply
```

`terraform plan`:

```text
reads configuration
reads state
reads Azure
calculates differences
shows proposed actions
```

but does not make the infrastructure changes.

The deployment workflow creates a saved plan:

```powershell
terraform plan -out=tfplan
```

and then applies that exact plan:

```powershell
terraform apply tfplan
```

This makes the plan reviewed by the deployment workflow the plan that Terraform actually executes.

---

## 8. Safe Module Refactoring

When the Terraform configuration was refactored into modules, the existing remote state key was preserved:

```text
data-platform/dev.tfstate
```

Changing to a new empty state key would have made Terraform believe the already-deployed Azure platform did not exist in its state.

That could have produced a plan proposing large numbers of new resources.

The project therefore preserved the existing backend state and used `moved` blocks to change addresses safely.

The safety rule used during migration was:

```text
Unexpected mass add/destroy plan
          |
          v
        STOP
          |
          v
Do not run terraform apply
```

---

## 9. Configuration Errors Caught Before Deployment

Several smaller Terraform configuration issues were also encountered during development, including:

```text
Reference to undeclared local value
```

after changing:

```text
local.tags
```

to:

```text
local.common_tags
```

and:

```text
Reference to undeclared input variable
```

for:

```text
var.alert_email
```

These errors reinforced why the CI pipeline now runs:

```text
terraform fmt
TFLint
Trivy
terraform validate
terraform plan
```

before deployment.

---

## 10. Operational Troubleshooting Approach Developed

The troubleshooting pattern used throughout the project became:

```text
1. Read the exact Terraform/Azure error
        |
        v
2. Identify the failing Azure operation
        |
        v
3. Determine whether the issue is:
   - Terraform configuration
   - state
   - authentication
   - Azure RBAC
   - resource-provider registration
   - networking
   - service configuration
        |
        v
4. Inspect Azure CLI / Terraform state
        |
        v
5. Correct the root cause
        |
        v
6. Run terraform plan again
        |
        v
7. Confirm the proposed change is safe
        |
        v
8. Apply
```

This troubleshooting experience became an important outcome of the project in addition to the infrastructure itself.

---

# 50. Key Lessons Learned

## Terraform State Is Critical

Terraform state is not just a cache. It is fundamental to how Terraform maps configuration to real infrastructure.

Remote state is essential for collaborative and automated infrastructure delivery.

## Resource Addresses Matter

Refactoring:

```text
azurerm_storage_account.datalake
```

to:

```text
module.storage.azurerm_storage_account.datalake
```

changes the Terraform resource address even when the Azure resource itself stays the same.

This is why `moved` blocks were necessary.

## Networking, Identity and Authorization Are Different

A useful mental model is:

```text
NETWORKING
Can I reach it?

IDENTITY
Who am I?

AUTHORIZATION
What am I allowed to do?
```

All three need to work for secure platform access.

## Logs and Metrics Are Different

Metrics tell operators that something is wrong.

Logs explain what happened.

## CI and CD Should Not Have the Same Privileges

Pull Request validation and planning do not need the same permissions as infrastructure deployment.

Separating plan and apply identities provides a stronger security model.

## Modules Should Represent Logical Capabilities

A module should not exist simply because there is an Azure resource.

The modules in this project represent logical platform capabilities:

```text
networking
storage
keyvault
datafactory
monitoring
```

---

# 51. Mapping to a Data Platform Engineer Role

This project directly demonstrates experience relevant to a Data Platform Engineer role.

## Terraform / Infrastructure as Code

Implemented:

- Azure infrastructure using Terraform
- Remote state
- Modules
- Environment separation
- State refactoring
- Automated plans and deployments

## Azure Data Platform

Implemented:

- Azure Data Factory
- ADLS Gen2
- Key Vault
- Networking
- Identity
- RBAC

## CI/CD

Implemented:

- GitHub Actions
- Pull Request checks
- Terraform validation
- Terraform plan
- Deployment workflow
- Azure OIDC

## Security

Implemented:

- Private Endpoints
- Private DNS
- Managed identities
- Least privilege RBAC
- Secretless CI/CD
- Public network lockdown

## Monitoring / Observability

Implemented:

- Log Analytics
- Diagnostic settings
- KQL
- Azure Monitor alerts
- Action Groups
- Email notifications

## Operational Engineering

Implemented:

- State management
- Alerting
- Troubleshooting queries
- Security scanning
- Code-quality gates
- Safe state migration

---

# 52. Example Interview Summary

A concise way to explain the project:

> I designed and built an Azure data-platform environment using Terraform. I provisioned networking, ADLS Gen2, Key Vault, Azure Data Factory, RBAC and observability resources while using Azure Storage for remote Terraform state.
>
> I secured the platform using Private Endpoints, Private DNS, managed identities and least-privilege RBAC, and disabled public access to sensitive services after validating private connectivity.
>
> For observability, I integrated Data Factory, Storage and Key Vault with Log Analytics and Azure Monitor, wrote KQL queries for troubleshooting and auditing, and configured proactive alerts through Action Groups.
>
> I implemented GitHub Actions CI/CD using Azure OIDC so that no long-lived Azure client secret was required. Pull Requests run formatting, TFLint, Trivy, Terraform validation and Terraform plan before merge, while deployment uses a separate Azure identity and controlled apply workflow.
>
> As the platform grew, I refactored it into reusable networking, storage, Key Vault, Data Factory and monitoring modules. I used Terraform moved blocks to migrate the existing Terraform state into the module structure without recreating the deployed Azure resources, and structured the repository to support separate dev, test and production environments with independent remote state.

---

# 53. Future Improvements

Potential next improvements include:

- Azure Policy integration
- Defender for Cloud integration
- Microsoft Sentinel integration
- NSG and network flow logging
- Azure Firewall / centralised egress controls
- Customer-managed encryption keys
- Key Vault purge protection for production
- More granular production RBAC
- Separate Azure subscriptions for dev/test/prod
- Separate CI/CD identities per environment
- GitHub production approval gates
- Automated Terraform documentation
- Cost estimation in Pull Requests
- Policy-as-code
- Automated drift detection
- Scheduled Terraform plans
- Snowflake provisioning through Terraform
- Azure Databricks platform provisioning
- ServiceNow integration for platform alerts/incidents

---

# 54. Current Project Status

The following major milestones have been completed:

```text
[✓] Terraform bootstrap
[✓] Azure remote state
[✓] Azure Resource Group
[✓] Virtual Network
[✓] Subnets
[✓] ADLS Gen2
[✓] Landing / Raw / Curated containers
[✓] Azure Key Vault
[✓] Azure Data Factory
[✓] Managed Identity
[✓] Azure RBAC
[✓] Private Endpoints
[✓] Private DNS
[✓] ADF Managed Virtual Network
[✓] Managed Integration Runtime
[✓] ADF Managed Private Endpoints
[✓] Public access lockdown
[✓] Log Analytics
[✓] Diagnostic Settings
[✓] KQL troubleshooting
[✓] Azure Monitor Alerting
[✓] Action Group
[✓] GitHub Actions CI/CD
[✓] Azure OIDC authentication
[✓] Separate plan/apply identities
[✓] TFLint
[✓] Trivy IaC scanning
[✓] Terraform module refactor
[✓] Safe state migration with moved blocks
[✓] Dev environment root
[✓] Test environment structure
[✓] Prod environment structure
[✓] Separate environment state strategy
[✓] Pull Request workflow
[✓] Merge-to-main workflow
[✓] Azure provider-registration troubleshooting
[✓] OIDC/RBAC troubleshooting for plan and apply identities
[✓] Diagnostic Settings permission troubleshooting
[✓] Partial Terraform apply recovery
[✓] CI variable / environment-root troubleshooting
```

---

# 55. Final Outcome

The project progressed through the following maturity stages:

```text
Basic Terraform
      |
      v
Azure Infrastructure
      |
      v
Remote State
      |
      v
Data Platform
      |
      v
Security / Private Networking
      |
      v
Managed Identity / RBAC
      |
      v
Observability
      |
      v
CI/CD
      |
      v
OIDC
      |
      v
IaC Quality / Security Gates
      |
      v
Reusable Modules
      |
      v
Dev / Test / Prod Structure
```

The final result is a practical demonstration of Azure data-platform engineering using Terraform, secure cloud networking, CI/CD automation, observability, Infrastructure as Code best practices and reusable platform architecture.
