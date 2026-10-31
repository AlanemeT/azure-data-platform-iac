variable "subscription_id" {
  description = "Azure subscription ID used for the deployment"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
  default     = "UK South"
}

variable "environment" {
  description = "Environment being deployed"
  type        = string
  default     = "dev"


  validation {
    condition = contains(
      ["dev", "test", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, test, or prod."
  }
}

variable "alert_email" {
  description = "Email address used to receive Azure Monitor alerts"
  type        = string
  sensitive   = true
}
