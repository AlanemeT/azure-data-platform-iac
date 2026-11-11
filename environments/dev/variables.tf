variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(
      ["dev", "test", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "integration_subnet_prefixes" {
  type = list(string)
}

variable "private_endpoint_subnet_prefixes" {
  type = list(string)
}

variable "alert_email" {
  description = "Azure Monitor notification email"
  type        = string
  sensitive   = true
}

variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake Terraform service user"
  type        = string
}
