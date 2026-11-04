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