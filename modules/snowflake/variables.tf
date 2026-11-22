variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "azure_tenant_id" {
  description = "Microsoft Entra tenant ID used by the Snowflake storage integration"
  type        = string
}

variable "azure_stage_url" {
  description = "Azure Blob Storage path available to Snowflake"
  type        = string
}