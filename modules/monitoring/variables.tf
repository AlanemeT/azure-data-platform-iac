variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "data_factory_id" {
  type = string
}

variable "datalake_blob_service_id" {
  type = string
}

variable "keyvault_id" {
  type = string
}

variable "alert_email" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}