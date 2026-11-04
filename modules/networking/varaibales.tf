variable "resource_group_name" {
  description = "Resource group containing networking resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the platform VNet"
  type        = list(string)
}

variable "integration_subnet_prefixes" {
  description = "Address prefixes for integration subnet"
  type        = list(string)
}

variable "private_endpoint_subnet_prefixes" {
  description = "Address prefixes for private endpoint subnet"
  type        = list(string)
}

variable "tags" {
  description = "Common Azure tags"
  type        = map(string)
}